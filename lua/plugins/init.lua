return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require "configs.treesitter"
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
        "dhananjaylatkar/cscope_maps.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
            "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
            "echasnovski/mini.pick", -- optional [for picker="mini-pick"]
        },
        opts = {
            -- USE EMPTY FOR DEFAULT OPTIONS
            -- DEFAULTS ARE LISTED BELOW
        },
    },

    {
        "rmagatti/auto-session",
        lazy = false,

        ---enables autocomplete for opts
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            -- log_level = 'debug',
        },
    },

    -- Lualine
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },

    -- {
    -- 	"nvim-treesitter/nvim-treesitter",
    -- 	opts = {
    -- 		ensure_installed = {
    -- 			"vim", "lua", "vimdoc",
    --      "html", "css"
    -- 		},
    -- 	},
    -- },
}
