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

-- Treat Avalonia XAML (*.axaml) as XML so treesitter highlighting and the
-- XML language server (lemminx) attach to it. Neovim has no built-in
-- mapping for the .axaml extension.
--
-- Go HTML templates use the "html" filetype so the HTML, CSS, Tailwind,
-- Emmet and HTMX language servers all attach. gopls is configured for the
-- "html" filetype in lua/prime/lsp.lua as well.
vim.filetype.add({
    pattern = {
        [".*%.axaml"] = "xml",
        [".*%.gohtml"] = "html",
        [".*%.gohtmltmpl"] = "html",
        [".*%.tmpl"] = "gotmpl",
        [".*%.gotmpl"] = "gotmpl",
    },
})

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
                    ["@type"] = { fg = "#ea9a97" },
                    ["@type.builtin"] = { fg = "#ea9a97" },
                    ["@type.definition"] = { fg = "#ea9a97" },
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
        -- VS Code-like auto-closing/renaming of XML/XAML/HTML tags.
        -- .axaml uses the "xml" filetype, which this plugin supports.
        "windwp/nvim-ts-autotag",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = true,
                },
                per_filetype = {
                    xml = {
                        enable_close = true,
                        enable_rename = true,
                        enable_close_on_slash = true,
                    },
                },
            })
        end,
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
            vim.keymap.set("n", "<leader>pa", function()
                builtin.find_files({
                    hidden = true,
                    no_ignore = true,
                    no_ignore_parent = true,
                })
            end, { desc = "Find all files (incl. hidden + ignored)" })
        end
    },

    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua",
                    "go",
                    "gotmpl",
                    "html",
                    "css",
                    "javascript",
                    "typescript",
                    "c",
                    "rust",
                    "yaml",
                    "c_sharp",
                    "xml",
                },
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
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", config = true },
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            require("prime.lsp").setup()
        end,
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
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept = "<C-l>",
                        next = "<C-j>",
                        prev = "<C-k>",
                        dismiss = "<C-h>",
                    },
                },
                panel = { enabled = true },
            })
        end,
    },

    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end,
    },

    {
        "ThePrimeagen/vim-be-good",
        keys = {
            {
                "<leader>vg",
                function()
                    vim.cmd("enew")
                    vim.cmd("VimBeGood")
                end,
                desc = "Vim Be Good (practice motions)",
            },
        },
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
})
