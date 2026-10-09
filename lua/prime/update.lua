-- Update checker + updater for prime-nvim.
--
-- On startup this asks GitHub for the latest VERSION file (async, short
-- timeout, at most once a day) and warns if the template is behind. The pull
-- itself is left to `prime update` / `:PrimeUpdate`, so nothing changes under
-- your feet without you asking.

local M = {}

local REPO = "moawedmohamed/prime-nvim"
local BRANCH = "main"
local VERSION_URL = ("https://raw.githubusercontent.com/%s/%s/VERSION"):format(REPO, BRANCH)
local CHECK_INTERVAL = 60 * 60 * 24 -- re-check at most once per day

local function config_dir()
    return vim.fn.stdpath("config")
end

--- Current template version, read from the VERSION file at the config root.
function M.version()
    local f = io.open(config_dir() .. "/VERSION", "r")
    if not f then
        return "0.0.0"
    end
    local v = f:read("*l") or "0.0.0"
    f:close()
    return (v:gsub("%s+", ""))
end

local function parse(v)
    v = (v or ""):gsub("^v", "")
    local major, minor, patch = v:match("^(%d+)%.(%d+)%.?(%d*)")
    return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch ~= "" and patch or "0") or 0
end

local function is_newer(remote, local_version)
    local r1, r2, r3 = parse(remote)
    local l1, l2, l3 = parse(local_version)
    if r1 ~= l1 then return r1 > l1 end
    if r2 ~= l2 then return r2 > l2 end
    return r3 > l3
end

local function state_file()
    return vim.fn.stdpath("state") .. "/prime-update-check"
end

local function last_checked()
    local f = io.open(state_file(), "r")
    if not f then return 0 end
    local t = tonumber(f:read("*l")) or 0
    f:close()
    return t
end

local function mark_checked()
    pcall(function()
        local f = io.open(state_file(), "w")
        if f then
            f:write(tostring(os.time()))
            f:close()
        end
    end)
end

function M.notify_available(remote)
    vim.notify(
        ("prime-nvim update available: %s -> %s\nRun `prime update` (or :PrimeUpdate) to upgrade.")
            :format(M.version(), remote),
        vim.log.levels.WARN,
        { title = "prime-nvim" }
    )
end

--- Async, throttled check for a newer published version.
function M.check(opts)
    opts = opts or {}
    if vim.env.PRIME_NO_UPDATE_CHECK and vim.env.PRIME_NO_UPDATE_CHECK ~= "" then
        return
    end
    if not opts.force and (os.time() - last_checked()) < CHECK_INTERVAL then
        return
    end
    if vim.fn.executable("curl") ~= 1 then
        return
    end

    vim.system({ "curl", "-fsSL", "--max-time", "3", VERSION_URL }, { text = true }, function(obj)
        vim.schedule(function()
            if obj.code ~= 0 or not obj.stdout or obj.stdout == "" then
                return
            end
            mark_checked()
            local remote = (obj.stdout:gsub("%s+", ""))
            if is_newer(remote, M.version()) then
                M.notify_available(remote)
            end
        end)
    end)
end

--- Pull the latest template inside the running editor.
function M.update()
    if vim.fn.executable("git") ~= 1 then
        vim.notify("prime-nvim: git not found; cannot update.", vim.log.levels.ERROR)
        return
    end
    vim.notify("prime-nvim: pulling the latest template...", vim.log.levels.INFO)
    vim.system({ "git", "-C", config_dir(), "pull", "--ff-only" }, { text = true }, function(obj)
        vim.schedule(function()
            if obj.code == 0 then
                vim.notify("prime-nvim updated. Restart Neovim to load the changes.", vim.log.levels.INFO)
            else
                vim.notify("prime-nvim update failed:\n" .. (obj.stderr or "unknown error"), vim.log.levels.ERROR)
            end
        end)
    end)
end

vim.api.nvim_create_user_command("PrimeUpdate", M.update, { desc = "Update prime-nvim from GitHub" })
vim.api.nvim_create_user_command("PrimeVersion", function()
    vim.notify("prime-nvim " .. M.version())
end, { desc = "Show the installed prime-nvim version" })

function M.setup()
    M.check()
end

return M
