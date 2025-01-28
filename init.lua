if vim.g.vscode then
    -- VSCode Neovim
    require "user.vscode_keymaps"
else
    -- Ordinary Neovim
    local vim = vim
    local Plug = vim.fn["plug#"]

    vim.call "plug#begin"
    Plug "neovim/nvim-lspconfig"
    Plug "hrsh7th/cmp-nvim-lsp"
    Plug "hrsh7th/cmp-buffer"
    Plug "hrsh7th/cmp-path"
    Plug "hrsh7th/cmp-cmdline"
    Plug "hrsh7th/nvim-cmp"
    Plug "hrsh7th/cmp-vsnip"
    Plug "hrsh7th/vim-vsnip"
    Plug "propet/toggle-fullscreen.nvim"
    vim.call "plug#end"

    vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
    vim.g.mapleader = " "

    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.o.number = true
    vim.o.cursorcolumn = true
    -- disable netrw at the very start of your init.lua
    --  optionally enable 24-bit colour
    vim.opt.termguicolors = true
    vim.opt.nu = true
    vim.opt.relativenumber = false
    vim.o.statuscolumn = "%s %l %r "
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
    vim.opt.laststatus = 3

    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 1
    vim.o.foldenable = true

    -- bootstrap lazy and all plugins
    local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

    if not vim.uv.fs_stat(lazypath) then
        local repo = "https://github.com/folke/lazy.nvim.git"
        vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
    end

    vim.opt.rtp:prepend(lazypath)

    local lazy_config = require "configs.lazy"

    -- load plugins
    require("lazy").setup({
        {
            "NvChad/NvChad",
            lazy = false,
            branch = "v2.5",
            import = "nvchad.plugins",
        },

        { import = "plugins" },
    }, lazy_config)

    -- Set up nvim-cmp.
    local cmp = require "cmp"
    cmp.setup {
        snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            end,
        },
        window = {
            -- completion = cmp.config.window.bordered(),
            -- documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        },
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "vsnip" }, -- For vsnip users.
        }, {
            { name = "buffer" },
        }),
    }

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer" },
        },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        }, {
            { name = "buffer" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
    })

    local cmp_nvim_lsp = require "cmp_nvim_lsp"

    require("lspconfig").clangd.setup {
        on_attach = on_attach,
        capabilities = cmp_nvim_lsp.default_capabilities(),
        cmd = {
            "clangd",
            "--offset-encoding=utf-16",
        },
    }

    -- load theme
    dofile(vim.g.base46_cache .. "defaults")
    dofile(vim.g.base46_cache .. "statusline")

    require "options"
    require "nvchad.autocmds"

    require("nvim-tree").setup {
        hijack_netrw = true,
        hijack_cursor = true,
        update_cwd = false,
        actions = {
            open_file = {
                quit_on_open = true,
            },
            change_dir = {
                enable = false,
                global = false,
            },
        },
        update_focused_file = {
            enable = true,
            update_cwd = false,
            ignore_list = {},
        },
        git = {
            enable = true,
            ignore = false,
            timeout = 500,
        },
    }

    require("cscope_maps").setup {
        cscope = {
            -- location of cscope db file
            --db_file = "./cscope.out",
        },
    }

    require("auto-session").setup {}

    require("cmp").setup {
        sources = {
            { name = "nvim_lsp" },
            { name = "render-markdown" },
        },
    }

    require("telescope").setup {}

    require("img-clip").setup {}
    require("render-markdown").setup {}
    require("copilot").setup {}
    require("avante_lib").load()
    require("avante").setup {}
    --[[
require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return { 'lsp', 'indent' }
    end
})

vim.keymap.set("n", "-", "<cmd>foldclose<CR>", { desc = "close the folder" })
vim.keymap.set("n", "+", "<cmd>foldopen<CR>", { desc = "Open the folder" })
vim.keymap.set("n", "zR", require('ufo').openAllFolds { desc = "open all folds" })
vim.keymap.set("n", "zM", require('ufo').closeAllFolds { desc = "close all folds" })
]]
    --

    local builtin = require "telescope.builtin"
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    vim.keymap.set("n", "<leader>fd", builtin.grep_string, { desc = "Telescope on curesor word live-grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    vim.keymap.set("n", "<leader>ft", builtin.lsp_document_symbols, { desc = "Telescope current buffer tags" })

    local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set("n", "<leader>e", api.tree.toggle, opts "Toggle Explorer")
        vim.keymap.set("n", "?", api.tree.toggle_help, opts "Help")
    end

    -- pass to setup along with your other options
    require("nvim-tree").setup {
        ---
        on_attach = my_on_attach,
        ---
    }

    require("dap-python").setup "/Users/kuldeepsingh/.virtualenvs/debugpy/bin/python"

    -- nvim dap mappings
    vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle the break point" })
    vim.keymap.set("n", "<F2>", require("dap").toggle_breakpoint)

    vim.keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>", { desc = "run or continue the debugger" })
    vim.keymap.set("n", "<F5>", require("dap").continue)

    vim.keymap.set("n", "<leader>dn", require("dap").step_over)
    vim.keymap.set("n", "<F7>", require("dap").step_over)

    vim.keymap.set("n", "<leader>di", require("dap").step_into)
    vim.keymap.set("n", "<F8>", require("dap").step_into)

    vim.keymap.set("n", "<leader>do", require("dap").step_out)
    vim.keymap.set("n", "<F9>", require("dap").step_out)

    local dap, dapui = require "dap", require "dapui"
    dapui.setup()

    -- open Dap UI automatically when debug starts (e.g. after <F5>)
    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end

    -- close Dap UI with :DapCloseUI
    vim.api.nvim_create_user_command("DapCloseUI", function()
        require("dapui").close()
    end, {})

    -- use <CTRL-e> to eval expressions
    vim.keymap.set({ "n", "v" }, "<C-e>", function()
        require("dapui").eval()
    end)

    local dap = require "dap"
    dap.configurations.cpp = {
        {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp

    require("symbols-outline").setup()
    vim.keymap.set("n", "<leader>ts", "<cmd>SymbolsOutline<CR>", { desc = "Toggle the symbol outline" })

    require("toggleterm").setup()
    vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle the terminal" })

    vim.keymap.set("n", "<leader>tu>", vim.cmd.UndotreeToggle)

    require("noice").setup {
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
        },
        -- you can enable a preset for easier configuration
        presets = {
            bottom_search = true, -- use a classic bottom cmdline for search
            command_palette = true, -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false, -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false, -- add a border to hover docs and signature help
        },
    }
    vim.keymap.set("n", "<leader>az", "<Cmd>lua require('toggle-fullscreen'):toggle_fullscreen()<CR>")

    vim.schedule(function()
        require "mappings"
    end)
end
