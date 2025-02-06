return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.treesitter"
        end,
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "VeryLazy",
        opts = function()
            return require "configs.null-ls"
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require "configs.lspconfig"
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        --event = "VeryLazy",
        dependencies = { "nvim-lspconfig" },
        config = function()
            require "configs.mason-lspconfig"
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.lint"
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
        event = "BufWritePre",
        config = function()
            require "configs.conform"
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
            -- ⚠️ This will only work if Telescope.nvim is installed
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
        opts = {
            ensure_installed = {
                "clangd",
                "clang-format",
                "codelldb",
            },
        },
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
                type = "server",
                port = "${port}",
                executable = {
                    command = "/Users/kuldeepsingh/.local/share/nvim/mason/bin/codelldb",
                    args = { "--port", "${port}" },
                },
            }
        end,
    },

    {
        "mfussenegger/nvim-dap-python",
        dependencies = {
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        ft = { "python" },
        config = function() end,
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
        config = function()
            require("gentags").setup()
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

    {
        "isakbm/gitgraph.nvim",
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
                    print("selected commit:", commit.hash)
                end,
                on_select_range_commit = function(from, to)
                    print("selected range:", from.hash, to.hash)
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
    {
        "isakbm/gitgraph.nvim",
        dependencies = { "sindrets/diffview.nvim" },
        ---@type I.GGConfig
        opts = {
            hooks = {
                -- Check diff of a commit
                on_select_commit = function(commit)
                    vim.notify("DiffviewOpen " .. commit.hash .. "^!")
                    vim.cmd(":DiffviewOpen " .. commit.hash .. "^!")
                end,
                -- Check diff from commit a -> commit b
                on_select_range_commit = function(from, to)
                    vim.notify("DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                    vim.cmd(":DiffviewOpen " .. from.hash .. "~1.." .. to.hash)
                end,
            },
        },
    },
    {
        "krisajenkins/telescope-docker.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            require("telescope").load_extension "telescope_docker"
            require("telescope_docker").setup {}
        end,

        -- Example keybindings. Adjust these to suit your preferences or remove
        --   them entirely:
        keys = {
            {
                "<Leader>dlv",
                ":Telescope telescope_docker docker_volumes<CR>",
                desc = "[D]ocker [V]olumes",
            },
            {
                "<Leader>dls",
                ":Telescope telescope_docker docker_images<CR>",
                desc = "[D]ocker [I]mages",
            },
            {
                "<Leader>dlp",
                ":Telescope telescope_docker docker_ps<CR>",
                desc = "[D]ocker [P]rocesses",
            },
        },
    },

    {
        "karb94/neoscroll.nvim",
        opts = {},
    },

    {
        "Xuyuanp/scrollbar.nvim",
        -- no setup required
        init = function()
            local group_id = vim.api.nvim_create_augroup("scrollbar_init", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "WinScrolled", "WinResized" }, {
                group = group_id,
                desc = "Show or refresh scrollbar",
                pattern = { "*" },
                callback = function()
                    require("scrollbar").show()
                end,
            })
        end,
    },

    {
        "sindrets/diffview.nvim",
    },

    {
        "RRethy/vim-illuminate",
    },

    {
        "m4xshen/smartcolumn.nvim",
        opts = {},
    },
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
}
