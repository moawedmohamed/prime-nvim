-- Clipboard that also works on headless boxes (remote SSH servers, containers,
-- WSL without a WSLg display, tmux-only sessions).
--
-- Why this is needed
-- ------------------
-- The keymaps in remap.lua target the `"+` register (`<leader>y`, `<leader>Y`,
-- `<C-c>`, `<C-x>`, `<C-v>`, `<C-r>+`). On a normal desktop Neovim proxies `+`
-- to a helper binary (xclip / xsel / wl-copy). But on a machine with no X11
-- and no Wayland those helpers cannot reach any display server, so the proxy
-- fails *silently*: the keymaps appear to work, the text just never leaves
-- Neovim. That is the single most confusing nvim-on-a-remote-server bug there
-- is, because nothing errors.
--
-- The fix
-- -------
-- When no native clipboard tool can work, fall back to OSC 52: Neovim
-- base64-encodes the text into an escape sequence and writes it to the
-- terminal, and the *local* terminal emulator writes it to the real OS
-- clipboard. Over SSH this is exactly what you want.
--
-- When a native tool does work we deliberately do nothing, so desktop setups
-- keep full two-way clipboard support (most terminals refuse OSC 52 *reads*,
-- so native is strictly better when available).

local M = {}

local function has_exe(name)
    return vim.fn.executable(name) == 1
end

local function env(name)
    local value = vim.env[name]
    return value ~= nil and value ~= ""
end

--- Returns the name of a usable native clipboard tool, or nil.
--- X11 needs a DISPLAY and wl-clipboard needs a Wayland socket; checking the
--- binary alone would pick xclip on a box that has no server to connect to.
function M.native_tool()
    if env("WAYLAND_DISPLAY") and (has_exe("wl-copy") or has_exe("wl-paste")) then
        return "wl-clipboard"
    end
    if env("DISPLAY") and (has_exe("xclip") or has_exe("xsel")) then
        return "xclip"
    end
    return nil
end

--- tmux only forwards OSC 52 when it is >= 3.2 (`set-clipboard`). Older tmux
--- silently eats the sequence, which makes the fallback look broken again.
function M.tmux_osc52_blocked()
    if not env("TMUX") or not has_exe("tmux") then
        return false
    end
    local version = vim.fn.system({ "tmux", "-V" }):match("tmux%s+(%d+%.%d+)")
    if not version then
        return true
    end
    local major, minor = version:match("(%d+)%.(%d+)")
    major, minor = tonumber(major), tonumber(minor)
    if not major or not minor then
        return true
    end
    return major < 3 or (major == 3 and minor < 2)
end

function M.status()
    local lines = {
        ("clipboard mode : %s (%s)"):format(M.mode or "unset", M.detail or "-"),
        ("DISPLAY        : %s"):format(env("DISPLAY") and vim.env.DISPLAY or "(unset)"),
        ("WAYLAND_DISPLAY: %s"):format(env("WAYLAND_DISPLAY") and vim.env.WAYLAND_DISPLAY or "(unset)"),
        ("'clipboard'    : %s"):format(vim.o.clipboard == "" and "(empty)" or vim.o.clipboard),
    }

    if M.mode == "osc52" then
        if M.tmux_osc52_blocked() then
            table.insert(lines, "WARNING       : tmux < 3.2 does not forward OSC 52.")
            table.insert(lines, "                Run nvim outside tmux, or upgrade tmux and add")
            table.insert(lines, "                `set -g set-clipboard on` to your tmux.conf.")
        end
        table.insert(lines, "Yank works via the terminal. Paste (\"+p) needs a terminal that")
        table.insert(lines, "allows OSC 52 reads; otherwise use your terminal's own paste.")
    end

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

function M.setup()
    local native = M.native_tool()
    if native then
        M.mode, M.detail = "native", native
        return
    end

    -- No display server we can reach, so go through the terminal instead.
    --
    -- Two things that look right but silently emit nothing on Neovim 0.12.x,
    -- so keep them in mind before "simplifying" this back:
    --   * the documented `vim.g.clipboard = "osc52"` shorthand is a no-op there;
    --   * building separate "*" provider functions installs a second
    --     TermResponse autocmd and stops the "+ copy from firing.
    -- One copy fn and one paste fn, shared by both registers, is what works.
    local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
    if not ok then
        M.mode, M.detail = "unavailable", "Neovim is too old for OSC 52"
        vim.schedule(function()
            vim.notify("prime-nvim: OSC 52 clipboard unavailable, yanks stay local.", vim.log.levels.WARN)
        end)
        return
    end

    local copy_clipboard = osc52.copy("+")
    local paste_clipboard = osc52.paste("+")

    vim.g.clipboard = {
        name = "osc52",
        copy = {
            ["+"] = copy_clipboard,
            ["*"] = copy_clipboard,
        },
        paste = {
            ["+"] = paste_clipboard,
            ["*"] = paste_clipboard,
        },
        cache_enabled = 0,
    }

    M.mode = "osc52"
    M.detail = M.tmux_osc52_blocked() and "blocked by tmux < 3.2" or "ok"
end

vim.api.nvim_create_user_command("PrimeClipboard", M.status, {})

return M
