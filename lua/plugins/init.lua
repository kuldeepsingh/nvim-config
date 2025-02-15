return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.treesitter"
        end,
        run = ":TSUpdate",
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "VeryLazy",
        opts = function()
            return require "configs.null-ls"
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        priority = 100,
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "onsails/lspkind.nvim",
            "ray-x/cmp-treesitter",
            "L3MON4D3/LuaSnip",
        },
        event = "InsertEnter",
        config = function()
            local cmp = require "cmp"
            local luasnip = require "luasnip"
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                formatting = {
                    format = require("lspkind").cmp_format {
                        mode = "symbol_text",
                        menu = {
                            nvim_lsp = "[LSP]",
                            buffer = "[Buffer]",
                            latex_symbols = "[Latex]",
                            luasnip = "[LuaSnip]",
                        },
                    },
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                view = {
                    entries = {
                        name = "custom",
                        selection_order = "near_cursor",
                    },
                },
                mapping = cmp.mapping.preset.insert {
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "calc" },
                    { name = "path" },
                    { name = "treesitter" },
                },
            }
        end,
    },

    {
        "Exafunction/codeium.nvim",
        lazy = false,
        -- event = "InsertEnter",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("codeium").setup {}
        end,
    },

    {
        "NvChad/nvim-colorizer.lua",
        event = "BufRead *",
    },

    {
        "linrongbin16/lsp-progress.nvim",
        event = "BufRead *",
        config = config,
    },

    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = {
                border = "double",
            },
            floating_window_off_y = -1,
            hint_enable = false,
        },
        config = function(_, opts)
            require("lsp_signature").setup(opts)
        end,
    },

    -- {
    -- "neovim/nvim-lspconfig",
    -- lazy = false,
    -- },
    -- {
    --     "neovim/nvim-lspconfig",
    --     event = { "BufReadPre", "BufNewFile" },
    --     config = function()
    --         require("nvchad.configs.lspconfig").defaults()
    --         require "configs.lspconfig"
    --     end,
    -- },

    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "nvim-lspconfig" },
        config = function()
            require "configs.mason-lspconfig"
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = {
            "BufReadPre",
            "BufNewFile",
        },
        config = function()
            local lint = require "lint"

            lint.linters_by_ft = {
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                svelte = { "eslint_d" },
                python = { "pylint" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },

    {
        "rshkarin/mason-nvim-lint",
        --event = "VeryLazy",
        dependencies = { "nvim-lint" },
        config = function()
            require "configs.mason-lint"
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local conform = require "conform"

            conform.setup {
                formatters_by_ft = {
                    lua = { "stylua" },
                    svelte = { { "prettierd", "prettier", stop_after_first = true } },
                    astro = { { "prettierd", "prettier", stop_after_first = true } },
                    javascript = { { "prettierd", "prettier", stop_after_first = true } },
                    typescript = { { "prettierd", "prettier", stop_after_first = true } },
                    javascriptreact = { { "prettierd", "prettier", stop_after_first = true } },
                    typescriptreact = { { "prettierd", "prettier", stop_after_first = true } },
                    json = { { "prettierd", "prettier", stop_after_first = true } },
                    graphql = { { "prettierd", "prettier", stop_after_first = true } },
                    java = { "google-java-format" },
                    kotlin = { "ktlint" },
                    ruby = { "standardrb" },
                    markdown = { { "prettierd", "prettier", stop_after_first = true } },
                    erb = { "htmlbeautifier" },
                    html = { "htmlbeautifier" },
                    bash = { "beautysh" },
                    proto = { "buf" },
                    rust = { "rustfmt" },
                    yaml = { "yamlfix" },
                    toml = { "taplo" },
                    css = { { "prettierd", "prettier", stop_after_first = true } },
                    scss = { { "prettierd", "prettier", stop_after_first = true } },
                    go = { "gofmt" },
                    xml = { "xmllint" },
                    python = { "isort", "black" },
                },
                format_on_save = {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 500,
                },
            }
        end,
    },

    {
        "zapling/mason-conform.nvim",
        -- event = "VeryLazy",
        dependencies = { "conform.nvim" },
        config = function()
            require "configs.mason-conform"
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
            { "debugloop/telescope-undo.nvim" },
        },
        config = function()
            require("telescope").setup {
                pickers = {
                    find_files = {
                        theme = "ivy",
                    },
                },
                extensions = {
                    fzf = {},
                },
            }

            require("telescope").load_extension "fzf"
            require("telescope").load_extension "live_grep_args"
            require("telescope").load_extension "undo"

            vim.keymap.set("n", "<space>fh", require("telescope.builtin").help_tags)
            vim.keymap.set("n", "<space>fd", require("telescope.builtin").find_files)
            vim.keymap.set("n", "<space>en", function()
                require("telescope.builtin").find_files {
                    cwd = vim.fn.stdpath "config",
                }
            end)
            vim.keymap.set("n", "<space>ep", function()
                require("telescope.builtin").find_files {
                    cwd = vim.fs.joinpath(vim.fn.stdpath "data", "lazy"),
                }
            end)

            require("configs.multigrep").setup()
        end,
    },

    {
        "dhananjaylatkar/cscope_maps.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
            "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
            "echasnovski/mini.pick", -- optional [for picker="mini-pick"]
        },
        opts = {},
    },

    {
        "ludovicchabant/vim-gutentags",
        init = function()
            vim.g.gutentags_modules = { "cscope_maps" } -- This is required. Other config is optional
            vim.g.gutentags_cscope_build_inverted_index_maps = 1
            vim.g.gutentags_cache_dir = vim.fn.expand "~/.code/.gutentags"
            vim.g.gutentags_file_list_command = "fd -e c -e h"
            -- vim.g.gutentags_trace = 1
        end,
    },

    {
        "rmagatti/auto-session",
        lazy = false,
        keys = {
            -- Will use Telescope if installed or a vim.ui.select picker otherwise
            { "<leader>wr", "<cmd>SessionSearch<CR>", desc = "Session search" },
            { "<leader>ws", "<cmd>SessionSave<CR>", desc = "Save session" },
            { "<leader>wa", "<cmd>SessionToggleAutoSave<CR>", desc = "Toggle autosave" },
        },

        ---enables autocomplete for opts
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            -- This will only work if Telescope.nvim is installed
            -- The following are already the default values, no need to provide them if these are already the settings you want.
            session_lens = {
                -- If load_on_setup is false, make sure you use `:SessionSearch` to open the picker as it will initialize everything first
                load_on_setup = true,
                previewer = false,
                mappings = {
                    -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
                    delete_session = { "i", "<C-D>" },
                    alternate_session = { "i", "<C-S>" },
                    copy_session = { "i", "<C-Y>" },
                },
                -- Can also set some Telescope picker options
                -- For all options, see: https://github.com/nvim-telescope/telescope.nvim/blob/master/doc/telescope.txt#L112
                theme_conf = {
                    border = true,
                    -- layout_config = {
                    --   width = 0.8, -- Can set width and height as percent of window
                    --   height = 0.5,
                    -- },
                },
            },
        },
    },
    -- Lualine
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },

    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            -- suggested keymap
            { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
        },
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },

    -- Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup {}
        end,
    },

    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false, -- set this to "*" if you want to always pull the latest change, false to update on release
        opts = { provider = "copilot" },
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = "make",
        -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                -- support for image pasting
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },

    {
        "williamboman/mason.nvim",
        dependencies = {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            local mason = require "mason"

            local mason_tool_installer = require "mason-tool-installer"

            -- enable mason and configure icons
            mason.setup {
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            }

            mason_tool_installer.setup {
                ensure_installed = {
                    "lua-language-server",
                    "prettier", -- prettier formatter
                    "stylua", -- lua formatter
                    "isort", -- python formatter
                    "black", -- python formatter
                    "pylint", -- python linter
                    "eslint_d", -- js linter
                },
            }
        end,
    },

    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "leoluz/nvim-dap-go",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "williamboman/mason.nvim",
        },
        config = function()
            local dap = require "dap"
            local ui = require "dapui"

            require("dapui").setup()
            require("dap-go").setup()

            require("nvim-dap-virtual-text").setup {
                -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
                display_callback = function(variable)
                    local name = string.lower(variable.name)
                    local value = string.lower(variable.value)
                    if name:match "secret" or name:match "api" or value:match "secret" or value:match "api" then
                        return "*****"
                    end

                    if #variable.value > 15 then
                        return " " .. string.sub(variable.value, 1, 15) .. "... "
                    end

                    return " " .. variable.value
                end,
            }

            --Handled by nvim-dap-go
            dap.adapters.go = {
                type = "server",
                port = "17500",
                executable = {
                    command = "dlv",
                    args = { "dap", "-l", "127.0.0.1:${port}" },
                },
            }

            dap.adapters.codelldb = {
                name = "lldb server",
                host = "127.0.0.1",
                type = "server",
                port = "13387",
                executable = {
                    command = "/Users/kuldeepsingh/.local/share/nvim/mason/bin/codelldb",
                    args = { "--port", "13387" },
                },
            }
        end,
    },

    {
        "mfussenegger/nvim-dap-python",
        dependencies = { "mfussenegger/nvim-dap" },
        enabled = true,
        config = function()
            local status, dap = pcall(require, "dap")
            if not status then
                return
            end
            local dappython
            status, dappython = pcall(require, "dap-python")
            if not status then
                return
            end
            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file (justMyCode = false)",
                    program = "${file}",
                    justMyCode = false,
                },
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file with arguments (justMyCode = false)",
                    program = "${file}",
                    justMyCode = false,
                    args = function()
                        local args_string = vim.fn.input "Arguments: "
                        return vim.split(args_string, " +")
                    end,
                },
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file (console = integratedTerminal, justMyCode = false)",
                    program = "${file}",
                    console = "integratedTerminal",
                    justMyCode = false,
                    -- pythonPath = opts.pythonPath,
                },
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file with arguments (console = integratedTerminal, justMyCode = false)",
                    program = "${file}",
                    console = "integratedTerminal",
                    justMyCode = false,
                    -- pythonPath = opts.pythonPath,
                    args = function()
                        local args_string = vim.fn.input "Arguments: "
                        return vim.split(args_string, " +")
                    end,
                },
            }
        end,
    },

    {
        "simrat39/symbols-outline.nvim",
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show { global = false }
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    {
        "nvimdev/lspsaga.nvim",
    },

    {
        "akinsho/toggleterm.nvim",
    },

    {
        "mg979/vim-visual-multi",
        -- See https://github.com/mg979/vim-visual-multi/issues/241
        init = function()
            vim.g.VM_default_mappings = 0
            vim.g.VM_maps = {
                ["Find Under"] = "",
            }
            vim.g.VM_add_cursor_at_pos_no_mappings = 1
        end,
    },

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
    },

    {
        "linrongbin16/gentags.nvim",
        opts = {
            workspace = { ".root", ".git", ".svn", ".hg" },
        },
        config = function()
            require("gentags").setup(opts)
        end,
    },

    {
        "rachartier/tiny-code-action.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope.nvim" },
        },
        event = "LspAttach",
        config = function()
            require("tiny-code-action").setup()
        end,
    },

    {
        "zk-org/zk-nvim",
        config = function()
            require("zk").setup {
                -- See Setup section below
            }
        end,
    },

    {
        "leath-dub/snipe.nvim",
        keys = {
            {
                "gb",
                function()
                    require("snipe").open_buffer_menu()
                end,
                desc = "Open Snipe buffer menu",
            },
        },
        opts = {},
    },

    {
        "vhyrro/luarocks.nvim",
        priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
        config = true,
    },

    ---------------------------------------------------------------------------
    -- FIXME : dont know, how to operate this?
    ---------------------------------------------------------------------------
    {
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        version = "*",
        -- config = true,
        config = function()
            require("neorg").setup {
                load = {
                    ["core.defaults"] = {}, -- Loads default behaviour
                    ["core.concealer"] = {}, -- Adds pretty icons to your documents
                    ["core.ui.calendar"] = {},
                    ["core.completion"] = { config = { engine = "nvim-cmp", name = "[Norg]" } },
                    ["core.integrations.nvim-cmp"] = {},
                    -- ["core.concealer"] = { config = { icon_preset = "diamond" } },
                    ["core.esupports.metagen"] = { config = { type = "auto", update_date = true } },
                    ["core.qol.toc"] = {},
                    ["core.qol.todo_items"] = {},
                    ["core.looking-glass"] = {},
                    ["core.presenter"] = { config = { zen_mode = "zen-mode" } },
                    ["core.export"] = {},
                    ["core.export.markdown"] = { config = { extensions = "all" } },
                    ["core.summary"] = {},
                    ["core.tangle"] = { config = { report_on_empty = false } },
                    ["core.dirman"] = { -- Manages Neorg workspaces
                        config = {
                            workspaces = {
                                notes = "~/notes/notes",
                                work = "~/notes/work",
                            },
                            default_workspace = "work",
                        },
                    },
                },
            }
        end,
    },

    ---------------------------------------------------------------------------
    -- Gitgraph plugin
    ---------------------------------------------------------------------------
    {
        "isakbm/gitgraph.nvim",
        dependencies = { "sindrets/diffview.nvim" },
        opts = {
            symbols = {
                merge_commit = "M",
                commit = "*",
            },
            format = {
                timestamp = "%H:%M:%S %d-%m-%Y",
                fields = { "hash", "timestamp", "author", "branch_name", "tag" },
            },
            hooks = {
                on_select_commit = function(commit)
                    vim.notify("DiffviewOpen " .. commit.hash .. "^!")
                    vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
                    print("selected commit:", commit.hash)
                end,
                on_select_range_commit = function(from, to)
                    print("selected range:", from.hash, to.hash)
                    vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                    vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                end,
            },
        },
        keys = {
            {
                "<leader>gl",
                function()
                    require("gitgraph").draw({}, { all = true, max_count = 5000 })
                end,
                desc = "GitGraph - Draw",
            },
        },
    },

    ---------------------------------------------------------------------------
    -- Scroll smoothingly
    ---------------------------------------------------------------------------
    {
        "karb94/neoscroll.nvim",
        opts = {},
    },

    ---------------------------------------------------------------------------
    -- Git diff
    ---------------------------------------------------------------------------
    {
        "sindrets/diffview.nvim",
    },

    ---------------------------------------------------------------------------
    -- Illuminism similar word in the file as cursor
    ---------------------------------------------------------------------------
    {
        "RRethy/vim-illuminate",
    },

    ---------------------------------------------------------------------------
    -- 80th column line will appear only if any line crosses 80th column
    ---------------------------------------------------------------------------
    {
        "m4xshen/smartcolumn.nvim",
        opts = {},
    },

    ---------------------------------------------------------------------------
    -- Dashboard appears when nvim is used without any file
    ---------------------------------------------------------------------------
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        config = function()
            require("dashboard").setup {
                -- config
            }
        end,
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },

    {
        "nvzone/showkeys",
        cmd = "ShowkeysToggle",
        event = "VimEnter",
        opt = { position = "top-right", show_count = true },
    },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },
    {
        "roobert/action-hints.nvim",
        config = function()
            require("action-hints").setup {
                template = {
                    definition = { text = " ⊛", color = "#82d2e0" },
                    references = { text = " ↱%s", color = "#f6b596" },
                },
                use_virtual_text = true,
            }
        end,
    },

    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("hlchunk").setup {
                chunk = {
                    enable = true,
                    priority = 15,
                    style = {
                        { fg = "#737994" },
                        { fg = "#c21f30" },
                    },
                    use_treesitter = true,
                    chars = {
                        horizontal_line = "─",
                        vertical_line = "│",
                        left_top = "┌",
                        left_bottom = "└",
                        right_arrow = "─",
                    },
                    textobject = "",
                    max_file_size = 1024 * 1024,
                    error_sign = true,
                    -- animation related
                    duration = 300,
                    delay = 120,
                },
                line_num = {
                    enable = true,
                    style = "#7aa0de",
                    priority = 10,
                    use_treesitter = false,
                },
            }
        end,
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },

    {
        "windwp/nvim-ts-autotag",
        event = "BufRead *.html,*.js,*.jsx,*.ts,*.tsx",
        config = config,
    },

    {
        "RubixDev/mason-update-all",
    },

    {
        "kdheepak/lazygit.nvim",
        lazy = false,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("telescope").load_extension "lazygit"
        end,
    },

    {
        "declancm/maximize.nvim",
        config = true,
    },

    ---------------------------------------------------------------------------
    -- Yazi integration
    ---------------------------------------------------------------------------
    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        keys = {
            -- 👇 in this section, choose your own keymappings!
            {
                "<leader>-",
                mode = { "n", "v" },
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file",
            },
            {
                -- NOTE: this requires a version of yazi that includes
                -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
                "yazi",
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session",
            },
            {
                -- NOTE: this requires a version of yazi that includes
                -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
                "file",
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session",
            },
        },
        ---@type YaziConfig
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = true,
            keymaps = {
                show_help = "<f1>",
            },
        },
    },

    {
        "aaronhallaert/advanced-git-search.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-fugitive",
            "tpope/vim-rhubarb",
        },
    },

    ---------------------------------------------------------------------------
    --  Text file dictionary
    ---------------------------------------------------------------------------
    {
        "uga-rosa/cmp-dictionary",
    },

    ---------------------------------------------------------------------------
    -- Diff 2 file d1 or d2 command
    ---------------------------------------------------------------------------
    {
        "jemag/telescope-diff.nvim",
        dependencies = {
            { "nvim-telescope/telescope.nvim" },
        },
    },

    ---------------------------------------------------------------------------
    -- Zen view - using 'zen' command on normal mode
    ---------------------------------------------------------------------------
    {
        "cdmill/focus.nvim",
        cmd = { "Focus", "Zen", "Narrow" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },

    ---------------------------------------------------------------------------
    -- twilight mode - focus on the current active code using 'dim' command
    ---------------------------------------------------------------------------
    {
        "folke/twilight.nvim",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
    },

    {
        "folke/trouble.nvim",
        opts = { focus = true }, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
}
