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
            { "hrsh7th/nvim-cmp", commit = "7d850f3" },
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
                ensure_installed = {
                    -- Go
                    "gopls",
                    -- frontend / web
                    "ts_ls",
                    "html",
                    "cssls",
                    "tailwindcss",
                    "eslint",
                    "jsonls",
                    "emmet_language_server",
                    "prismals",
                    -- devops
                    "dockerls",
                    "docker_compose_language_service",
                    -- others
                    "lua_ls",
                    "rust_analyzer",
                    "yamlls",
                },
            })

            -- nvim 0.12: per-server settings are applied with vim.lsp.config.
            -- (mason-lspconfig here enables servers via vim.lsp.enable; the old
            -- lsp-zero "handlers" table is ignored, so settings must go here.)
            vim.lsp.config("*", {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })

            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        usePlaceholders = true,
                        staticcheck = true,
                        completeUnimported = true,
                        gofumpt = true,
                        codelenses = {
                            gc_details = false,
                            generate = true,
                            regenerate_cgo = true,
                            run_govulncheck = true,
                            test = true,
                            tidy = true,
                            upgrade_dependency = true,
                            vendor = true,
                        },
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                        analyses = {
                            unusedparams = true,
                            shadow = true,
                        },
                    },
                },
            })

            vim.lsp.config("yamlls", {
                settings = {
                    yaml = {
                        schemas = {
                            ["https://www.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                            ["https://www.schemastore.org/github-action.json"] = ".github/actions/*.{yml,yaml}",
                            ["https://raw.githubusercontent.com/compose-spec/compose-go/master/schema/compose-spec.json"] =
                            "*compose*.{yml,yaml}",
                            ["https://www.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                            ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.30.0-standalone-strict/all.json"] = {
                                "*.k8s.yaml",
                                "*.k8s.yml",
                            },
                        },
                        format = {
                            enable = true,
                        },
                    },
                },
            })

            vim.lsp.config("dockerls", {
                settings = {
                    docker = {
                        languages = {
                            dockerfile = { enabled = true },
                        },
                    },
                },
            })

            lsp.on_attach(function(client, bufnr)
                lsp.default_keymaps({ buffer = bufnr })
                local opts = { buffer = bufnr }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })
                vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol,
                    { buffer = bufnr, desc = "Document symbols" })
                vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol,
                    { buffer = bufnr, desc = "Workspace symbols" })
            end)

            lsp.setup()

            -- docker-compose files use the dedicated compose language server,
            -- which only starts for the custom 'yaml.docker-compose' filetype.
            vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                pattern = {
                    "docker-compose*.yaml",
                    "docker-compose*.yml",
                    "compose*.yaml",
                    "compose*.yml",
                },
                callback = function()
                    vim.bo.filetype = "yaml.docker-compose"
                end,
            })

            -- Diagnostics: inline virtual text, coloured underline, signs and
            -- a rounded floating window. update_in_insert = false keeps the
            -- buffer calm while typing.
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    source = "if_many",
                    spacing = 2,
                },
                underline = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "E",
                        [vim.diagnostic.severity.WARN] = "W",
                        [vim.diagnostic.severity.INFO] = "I",
                        [vim.diagnostic.severity.HINT] = "H",
                    },
                },
                severity_sort = true,
                update_in_insert = false,
                float = {
                    border = "rounded",
                    source = true,
                    header = "",
                    prefix = "",
                },
            })

            -- NOTE: the 'd' prefix is intentionally avoided here -- remap.lua
            -- maps <leader>d to the delete operator, so a paused <leader>d
            -- would start deleting instead of waiting for a diagnostic key.
            local function diag_goto(count)
                if #vim.diagnostic.get(0) == 0 then
                    vim.notify("No diagnostics in this buffer", vim.log.levels.INFO)
                    return
                end
                vim.diagnostic.jump({ count = count, float = true })
            end

            vim.keymap.set("n", "gj", function()
                diag_goto(1)
            end, { desc = "Next diagnostic" })
            vim.keymap.set("n", "gk", function()
                diag_goto(-1)
            end, { desc = "Previous diagnostic" })
            vim.keymap.set("n", "<leader>cd", function()
                local line = vim.api.nvim_win_get_cursor(0)[1] - 1
                if #vim.diagnostic.get(0, { lnum = line }) == 0 then
                    vim.notify("No diagnostic on this line", vim.log.levels.INFO)
                else
                    vim.diagnostic.open_float()
                end
            end, { desc = "Show diagnostic (float)" })

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
                        if vim.bo.filetype == "go" then
                            pcall(vim.lsp.buf.code_action, {
                                context = {
                                    only = { "source.organizeImports" },
                                    diagnostics = {},
                                },
                                apply = true,
                            })
                        end
                    end
                end,
            })

            local cmp = require("cmp")
            -- registers the nvim_lsp completion source on each InsertEnter;
            -- without this no LSP suggestions ever reach nvim-cmp.
            require("cmp_nvim_lsp").setup()
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_lua").load({
                paths = vim.fn.stdpath("config") .. "/lua/prime/snippets",
            })
            -- docker-compose files use the "yaml.docker-compose" filetype;
            -- let them also use the plain "yaml" snippet library.
            luasnip.filetype_extend("yaml.docker-compose", { "yaml" })

            vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
                    { name = "codeium" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "luasnip" },
                }),
            })
        end
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local gs = require("gitsigns")
            gs.setup({
                signs = {
                    add = { text = "▎" },
                    change = { text = "▎" },
                    delete = { text = "▁" },
                    topdelete = { text = "▔" },
                    changedelete = { text = "▎" },
                },
                on_attach = function(bufnr)
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                    end
                    map("n", "<leader>hn", gs.next_hunk, "Next git hunk")
                    map("n", "<leader>hp", gs.prev_hunk, "Previous git hunk")
                    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                    map("n", "<leader>hv", gs.preview_hunk, "Preview git hunk")
                    map("n", "<leader>hs", gs.stage_hunk, "Stage git hunk")
                    map("n", "<leader>hr", gs.reset_hunk, "Reset git hunk")
                    map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
                    map("n", "<leader>hd", gs.diffthis, "Diff this file")
                end,
            })
        end,
    },

    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("Comment").setup()
        end,
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({})
            wk.add({
                { "gj",        desc = "Next diagnostic" },
                { "gk",        desc = "Previous diagnostic" },
                { "<leader>v", group = "lsp" },
                { "<leader>h", group = "hunks / terminal" },
            })
        end,
    },

    {
        "github/copilot.vim",
        event = "InsertEnter",
        config = function()
            vim.g.copilot_no_tab_map = true
            vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false })
        end,
    },
})
