local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                styles = {
                    background = "dark",
                },
                highlight_groups = {
                    Normal = { bg = "#000000" },
                    NormalFloat = { bg = "#000000" },
                    ColorColumn = { bg = "#16171d" },
                    SignColumn = { bg = "#000000" },
                    StatusLine = { bg = "#000000" },
                    TelescopeNormal = { bg = "#000000" },
                },
            })
            vim.cmd("colorscheme rose-pine")
            vim.g.rose_pine_variant = "moon"
            vim.cmd("colorscheme rose-pine-moon")
        end
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end
    },

    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
            vim.keymap.set("n", "<C-p>", builtin.git_files, {})
            vim.keymap.set("n", "<leader>ps", function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)
        end
    },

    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "go", "typescript", "c", "rust", "yaml" },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },

    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

            vim.keymap.set("n", "<C-h>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<C-l>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<C-n>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<C-s>", function() ui.nav_file(4) end)
        end
    },

    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },

    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "rose-pine" }
            })
        end
    },

    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local lsp = require("lsp-zero").preset({
                name = "recommended",
            })

            require("mason").setup({})
            require("mason-lspconfig").setup({
                ensure_installed = { "rust_analyzer", "gopls", "lua_ls", "ts_ls", "yamlls" },
                handlers = {
                    require("lsp-zero").default_setup,
                },
            })

            lsp.on_attach(function(client, bufnr)
                lsp.default_keymaps({ buffer = bufnr })
                local opts = { buffer = bufnr }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
            end)

            lsp.setup()

            local diag_win = nil
            local diag_buf = nil

            local function close_diag()
                if diag_win and vim.api.nvim_win_is_valid(diag_win) then
                    vim.api.nvim_win_close(diag_win, true)
                end
                diag_win, diag_buf = nil, nil
            end

            local function toggle_diag()
                if diag_win and vim.api.nvim_win_is_valid(diag_win) then
                    close_diag()
                    return
                end
                local diags = vim.diagnostic.get(0)
                if #diags == 0 then
                    vim.notify("No diagnostics")
                    return
                end
                local severities = { "ERROR", "WARN", "INFO", "HINT" }
                local lines = {}
                for _, d in ipairs(diags) do
                    local sev = severities[d.severity] or "?"
                    local msg = d.message:gsub("[\r\n]+", " ")
                    table.insert(lines, string.format(
                        "%s %d:%d  %s",
                        sev, d.lnum + 1, d.col + 1, msg
                    ))
                end
                diag_buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(diag_buf, 0, -1, false, lines)
                local width = vim.api.nvim_win_get_width(0)
                local height = math.min(#lines + 2, vim.api.nvim_win_get_height(0) - 4)
                local opts = {
                    relative = "editor",
                    row = 1,
                    col = 0,
                    width = math.min(width - 4, 100),
                    height = height,
                    style = "minimal",
                    border = "rounded",
                }
                diag_win = vim.api.nvim_open_win(diag_buf, false, opts)
                vim.api.nvim_buf_set_keymap(diag_buf, "n", "q", "", {
                    callback = close_diag,
                })
                vim.api.nvim_buf_set_keymap(diag_buf, "n", "<Enter>", "", {
                    callback = function()
                        local line = vim.api.nvim_win_get_cursor(diag_win)[1] - 1
                        local target = diags[line + 1]
                        if target then
                            close_diag()
                            vim.api.nvim_win_set_cursor(0, { target.lnum + 1, target.col })
                        end
                    end,
                })
            end

            vim.keymap.set("n", "<leader>xx", toggle_diag)

            vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
                callback = function()
                    if diag_win then
                        close_diag()
                    end
                end,
            })

            vim.api.nvim_create_autocmd("BufWritePre", {
                callback = function()
                    local clients = vim.lsp.get_clients({ bufnr = 0 })
                    if vim.bo.modifiable and next(clients) ~= nil then
                        vim.lsp.buf.format({ bufnr = 0, async = false })
                    end
                end,
            })

            local cmp = require("cmp")
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_lua").load({
                paths = vim.fn.stdpath("config") .. "/lua/prime/snippets",
            })

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-@>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        elseif luasnip.expandable() then
                            luasnip.expand()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = "insert" }),
                    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = "insert" }),
                    ["<Down>"] = cmp.mapping.select_next_item({ behavior = "insert" }),
                    ["<Up>"] = cmp.mapping.select_prev_item({ behavior = "insert" }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = "insert" })
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item({ behavior = "insert" })
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                completion = {
                    autocomplete = { cmp.TriggerEvent.TextChanged },
                    keyword_length = 1,
                },
                preselect = cmp.PreselectMode.Item,
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "luasnip" },
                }),
            })
        end
    },
})
