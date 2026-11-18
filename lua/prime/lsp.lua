local M = {}

function M.setup()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local function is_template_buffer()
        return vim.tbl_contains({ "html", "gohtmltmpl", "gotmpl" }, vim.bo.filetype)
    end

    -- gopls advertises formatting for template buffers but formats the Go
    -- actions only, which strips the surrounding HTML. Keep it out of
    -- formatting so the HTML server owns markup.
    local function format_filter(client)
        return not (client.name == "gopls" and is_template_buffer())
    end

    -- Mason installs the language servers.
    require("mason").setup({})

    -- Neovim 0.11+ native LSP API. `*` applies to every server, so the
    -- completion capabilities are shared without the deprecated
    -- `require('lspconfig')` framework.
    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    -- lemminx (XML/XAML). XAML (Avalonia) has no DTD/XSD: hide the noisy
    -- "No grammar constraints" hint.
    vim.lsp.config("lemminx", {
        settings = {
            xml = {
                validation = {
                    enabled = true,
                    noGrammar = "ignore",
                },
                format = { enabled = true },
            },
        },
    })

    vim.lsp.config("gopls", {
        -- Also attach to HTML templates, so gopls can complete and check the
        -- Go actions inside {{ ... }}. templateExtensions below tells gopls
        -- which extensions are Go templates.
        filetypes = { "go", "gomod", "gowork", "gotmpl", "html", "gohtmltmpl" },
        settings = {
            gopls = {
                templateExtensions = { "html", "gohtml", "gohtmltmpl", "tmpl", "gotmpl" },
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
                    ["https://json.schemastore.org/github-workflow.json"] =
                    ".github/workflows/*.{yml,yaml}",
                    ["https://json.schemastore.org/github-action.json"] =
                    ".github/actions/*.{yml,yaml}",
                    ["https://json.schemastore.org/docker-compose.json"] =
                    "docker-compose*.{yml,yaml}",
                    ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                    ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.29.0-standalone-strict/all.json"] = {
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

    -- C# via csharp-ls (installed with `dotnet tool install --global csharp-ls`).
    -- Kept out of Mason's ensure_installed so we reuse the global dotnet-tool
    -- binary. csharp-ls switches to *pull* diagnostics when the client
    -- advertises `textDocument.diagnostic`, but Neovim only enables pull from
    -- LspAttach (after didOpen) so it never pulls and csharp-ls never pushes.
    -- Removing the capability (encode as JSON null) makes csharp-ls push
    -- diagnostics. It also advertises no static definitionProvider when the
    -- client claims `textDocument.definition.dynamicRegistration = true`, so
    -- force static capability instead of dynamic registration.
    vim.lsp.config("csharp_ls", {
        capabilities = {
            textDocument = {
                diagnostic = vim.NIL,
                definition = { dynamicRegistration = false },
            },
        },
    })

    -- HTMX attribute completion/hover. Built from upstream main because the
    -- 0.2.0 release sends an invalid empty completion response when it has no
    -- results, which Neovim reports as INVALID_SERVER_MESSAGE.
    local htmx_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "htmx-lsp", "htmx-lsp")
    vim.lsp.config("htmx", {
        cmd = { vim.fn.executable(htmx_bin) == 1 and htmx_bin or "htmx-lsp" },
        filetypes = { "html", "gohtmltmpl", "gotmpl" },
    })

    -- Go template files opened as "gotmpl" (e.g. .tmpl/.gotmpl) should get
    -- the same HTML-side tooling as .html/.gohtml files.
    local function add_filetype(server, filetype)
        local cfg = vim.lsp.config[server]
        if cfg and cfg.filetypes and not vim.tbl_contains(cfg.filetypes, filetype) then
            local filetypes = vim.deepcopy(cfg.filetypes)
            table.insert(filetypes, filetype)
            vim.lsp.config(server, { filetypes = filetypes })
        end
    end

    for _, server in ipairs({ "html", "emmet_language_server", "tailwindcss", "htmx" }) do
        add_filetype(server, "gotmpl")
    end

    -- mason-lspconfig enables every installed server via `vim.lsp.enable()`.
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
            "htmx",
            "prismals",
            -- devops
            "dockerls",
            "docker_compose_language_service",
            -- others
            "lua_ls",
            "rust_analyzer",
            "yamlls",
            -- markup / XAML (Avalonia .axaml is mapped to the xml filetype)
            "lemminx",
        },
    })

    -- csharp_ls is not managed by Mason, so enable it explicitly.
    vim.lsp.enable("csharp_ls")
    -- htmx uses the 0.2.0 binary installed outside Mason (see above).
    vim.lsp.enable("htmx")

    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local opts = { buffer = args.buf }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, opts)
            vim.keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts)
            vim.keymap.set("n", "<leader>f", function()
                vim.lsp.buf.format({ async = true, filter = format_filter })
            end, opts)
        end,
    })

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
                vim.lsp.buf.format({ bufnr = 0, async = false, filter = format_filter })
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
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_lua").load({
        paths = vim.fn.stdpath("config") .. "/lua/prime/snippets",
    })

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
            { name = "copilot" },
            { name = "nvim_lsp" },
            { name = "buffer" },
            { name = "path" },
            { name = "luasnip" },
        }),
    })
end

return M
