if vim.g.vscode then
    -- VSCode Neovim
    require "user.vscode_keymaps"
else
    -- Ordinary Neovim
    local vim = vim
    local Plug = vim.fn["plug#"]

    ------------------------------------------------
    --- LSP install
    ------------------------------------------------
    vim.call "plug#begin"
    Plug "neovim/nvim-lspconfig"
    Plug "hrsh7th/cmp-nvim-lsp"
    Plug "hrsh7th/cmp-buffer"
    Plug "hrsh7th/cmp-path"
    Plug "hrsh7th/cmp-cmdline"
    Plug "hrsh7th/nvim-cmp"
    Plug "hrsh7th/cmp-vsnip"
    Plug "hrsh7th/vim-vsnip"
    vim.call "plug#end"

    vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
    vim.g.mapleader = " "

    ---------------------------------------------------------------
    -- bootstrap lazy and all plugins
    ---------------------------------------------------------------
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

    ---------------------------------------------------------------
    -- Set up nvim-cmp.
    ---------------------------------------------------------------
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

    ---------------------------------------------------------------
    -- load theme
    ---------------------------------------------------------------
    dofile(vim.g.base46_cache .. "defaults")
    dofile(vim.g.base46_cache .. "statusline")

    require "options"
    require "nvchad.autocmds"

    ---------------------------------------------------
    --- Cscope map : Still needs to be configured
    ----------------------------------------------------
    require("cscope_maps").setup {
        cscope = {
            -- location of cscope db file
            --db_file = "./cscope.out",
        },
    }

    ----------------------------------------------------
    ---Save and restore the sessions
    ----------------------------------------------------
    require("auto-session").setup {}

    require("cmp").setup {
        sources = {
            { name = "nvim_lsp" },
            { name = "render-markdown" },
        },
    }

    ---------------------------------------------------
    -- Telescope config
    ----------------------------------------------------
    require("telescope").setup {}
    local builtin = require "telescope.builtin"
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
    --vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
    vim.keymap.set("n", "<leader>fd", builtin.grep_string, { desc = "Telescope on curesor word live-grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
    vim.keymap.set("n", "<leader>ft", builtin.lsp_document_symbols, { desc = "Telescope current buffer tags" })
    vim.keymap.set(
        "n",
        "<leader>fg",
        ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
        { desc = "Telescope current buffer tags" }
    )
    local live_grep_args_shortcuts = require "telescope-live-grep-args.shortcuts"
    vim.keymap.set(
        "n",
        "<leader>fc",
        live_grep_args_shortcuts.grep_word_under_cursor,
        { desc = "Telescope search buffer under cursor with directory option" }
    )

    require("telescope").load_extension "noice"

    require("img-clip").setup {}
    require("render-markdown").setup {}

    ---------------------------------------------------
    -- AI setup
    ----------------------------------------------------
    require("copilot").setup {}
    require("avante_lib").load()
    require("avante").setup {}

    ---------------------------------------------------
    -- nvim-tree Setup
    ----------------------------------------------------
    local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        --  CTRL+n is mappedi to open the file explorer

        vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "File Explorer" })
        vim.keymap.set("n", "?", api.tree.toggle_help, opts "Help")
    end

    -- pass to setup along with your other options
    require("nvim-tree").setup {
        ---
        on_attach = my_on_attach,
        ---
    }

    ----------------------------------------------------
    --- Debugging setup for Python
    ----------------------------------------------------
    require("dap-python").setup "/Users/kuldeepsingh/.virtualenvs/debugpy/bin/python"

    -- nvim dap mappings
    vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle the break point" })
    vim.keymap.set("n", "<F2>", require("dap").toggle_breakpoint)

    vim.keymap.set("n", "<leader>dr", "<cmd>DapContinue<CR>", { desc = "run or continue the debugger" })
    vim.keymap.set("n", "<F5>", require("dap").continue, { desc = "run or continue the debugger" })

    vim.keymap.set("n", "<leader>dn", require("dap").step_over, { desc = "Step Over" })
    vim.keymap.set("n", "<F7>", require("dap").step_over, { desc = "Step Over" })

    vim.keymap.set("n", "<leader>di", require("dap").step_into, { desc = "Step into" })
    vim.keymap.set("n", "<F8>", require("dap").step_into, { desc = "Step into" })

    vim.keymap.set("n", "<leader>do", require("dap").step_out, { desc = "Step out" })
    vim.keymap.set("n", "<F9>", require("dap").step_out, { desc = "Step out" })

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
    vim.keymap.set({ "n", "v" }, "<leader>de", function()
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

    ----------------------------------------------------
    --- Symbol outline
    ----------------------------------------------------
    require("symbols-outline").setup()
    vim.keymap.set("n", "<leader>ts", "<cmd>SymbolsOutline<CR>", { desc = "Toggle the symbol outline" })

    ----------------------------------------------------
    --Terminal App
    ----------------------------------------------------
    require("toggleterm").setup {
        persist_mode = false,
        direction = "horizontal",
        start_in_insert = true,
        ---float_opts = {
        ---    --border = "double" | "shadow" | "curved",
        ---    border = "double",
        ---},
    }
    vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle the terminal" })
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

    ----------------------------------------------------
    --- Undo Tree
    ----------------------------------------------------
    vim.keymap.set("n", "<leader>tu>", vim.cmd.UndotreeToggle, { desc = "Display the undo tree" })

    ----------------------------------------------------
    --- Noice notices
    ----------------------------------------------------
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

    vim.keymap.set("n", "<leader>cq", function()
        require("tiny-code-action").code_action()
    end, { noremap = true, silent = true })

    -- require("neorg").setup {
    --     load = {
    --         ["core.defaults"] = {},
    --         ["core.norg.concealer"] = {
    --             config = {
    --                 folds = false,
    --             },
    --         },
    --         ["core.norg.dirman"] = {
    --             config = {
    --                 workspaces = { notes = "~/.data/neorg" },
    --                 default_workspace = "notes",
    --             },
    --             index = "index.norg",
    --         },
    --         ["core.norg.completion"] = {
    --             config = {
    --                 engine = "nvim-cmp",
    --             },
    --         },
    --         ["core.export"] = {},
    --     },
    -- }

    -------------------------------------------------------------------
    ---Fast scrolling
    -------------------------------------------------------------------
    require("neoscroll").setup {
        mappings = { -- Keys to be mapped to their corresponding default scrolling animation
            "<C-u>",
            "<C-d>",
            "<C-b>",
            "<C-f>",
            "<C-y>",
            "<C-e>",
            "zt",
            "zz",
            "zb",
        },
        hide_cursor = true, -- Hide cursor while scrolling
        stop_eof = true, -- Stop at <EOF> when scrolling downwards
        respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        duration_multiplier = 1.0, -- Global duration multiplier
        easing = "linear", -- Default easing function
        pre_hook = nil, -- Function to run before the scrolling animation starts
        post_hook = nil, -- Function to run after the scrolling animation ends
        performance_mode = false, -- Disable "Performance Mode" on all buffers.
        ignored_events = { -- Events ignored while scrolling
            "WinScrolled",
            "CursorMoved",
        },
    }

    ---------------------------------------
    --- Diffview
    --- -----------------------------------
    local actions = require "diffview.actions"

    --- FIXME : fix the mapping for this to not conflict with others
    require("diffview").setup {
        diff_binaries = false, -- Show diffs for binaries
        enhanced_diff_hl = false, -- See |diffview-config-enhanced_diff_hl|
        git_cmd = { "git" }, -- The git executable followed by default args.
        hg_cmd = { "hg" }, -- The hg executable followed by default args.
        use_icons = true, -- Requires nvim-web-devicons
        show_help_hints = true, -- Show hints for how to open the help panel
        watch_index = true, -- Update views and index buffers when the git index changes.
        icons = { -- Only applies when use_icons is true.
            folder_closed = "",
            folder_open = "",
        },
        signs = {
            fold_closed = "",
            fold_open = "",
            done = "✓",
        },
        view = {
            -- Configure the layout and behavior of different types of views.
            -- Available layouts:
            --  'diff1_plain'
            --    |'diff2_horizontal'
            --    |'diff2_vertical'
            --    |'diff3_horizontal'
            --    |'diff3_vertical'
            --    |'diff3_mixed'
            --    |'diff4_mixed'
            -- For more info, see |diffview-config-view.x.layout|.
            default = {
                -- Config for changed files, and staged files in diff views.
                layout = "diff2_horizontal",
                disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
                winbar_info = false, -- See |diffview-config-view.x.winbar_info|
            },
            merge_tool = {
                -- Config for conflicted files in diff views during a merge or rebase.
                layout = "diff3_horizontal",
                disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
                winbar_info = true, -- See |diffview-config-view.x.winbar_info|
            },
            file_history = {
                -- Config for changed files in file history views.
                layout = "diff2_horizontal",
                disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
                winbar_info = false, -- See |diffview-config-view.x.winbar_info|
            },
        },
        file_panel = {
            listing_style = "tree", -- One of 'list' or 'tree'
            tree_options = { -- Only applies when listing_style is 'tree'
                flatten_dirs = true, -- Flatten dirs that only contain one single dir
                folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
            },
            win_config = { -- See |diffview-config-win_config|
                position = "left",
                width = 35,
                win_opts = {},
            },
        },
        file_history_panel = {
            log_options = { -- See |diffview-config-log_options|
                git = {
                    single_file = {
                        diff_merges = "combined",
                    },
                    multi_file = {
                        diff_merges = "first-parent",
                    },
                },
                hg = {
                    single_file = {},
                    multi_file = {},
                },
            },
            win_config = { -- See |diffview-config-win_config|
                position = "bottom",
                height = 16,
                win_opts = {},
            },
        },
        commit_log_panel = {
            win_config = {}, -- See |diffview-config-win_config|
        },
        default_args = { -- Default args prepended to the arg-list for the listed commands
            DiffviewOpen = {},
            DiffviewFileHistory = {},
        },
        hooks = {}, -- See |diffview-config-hooks|
        keymaps = {
            disable_defaults = false, -- Disable the default keymaps
            view = {
                -- The `view` bindings are active in the diff buffers, only when the current
                -- tabpage is a Diffview.
                {
                    "n",
                    "<tab>",
                    actions.select_next_entry,
                    { desc = "Open the diff for the next file" },
                },
                {
                    "n",
                    "<s-tab>",
                    actions.select_prev_entry,
                    { desc = "Open the diff for the previous file" },
                },
                {
                    "n",
                    "[F",
                    actions.select_first_entry,
                    { desc = "Open the diff for the first file" },
                },
                {
                    "n",
                    "]F",
                    actions.select_last_entry,
                    { desc = "Open the diff for the last file" },
                },
                {
                    "n",
                    "gf",
                    actions.goto_file_edit,
                    { desc = "Open the file in the previous tabpage" },
                },
                {
                    "n",
                    "<C-w><C-f>",
                    actions.goto_file_split,
                    { desc = "Open the file in a new split" },
                },
                {
                    "n",
                    "<C-w>gf",
                    actions.goto_file_tab,
                    { desc = "Open the file in a new tabpage" },
                },
                {
                    "n",
                    "<leader>e",
                    actions.focus_files,
                    { desc = "Bring focus to the file panel" },
                },
                { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel." } },
                {
                    "n",
                    "g<C-x>",
                    actions.cycle_layout,
                    { desc = "Cycle through available layouts." },
                },
                {
                    "n",
                    "[x",
                    actions.prev_conflict,
                    { desc = "In the merge-tool: jump to the previous conflict" },
                },
                {
                    "n",
                    "]x",
                    actions.next_conflict,
                    { desc = "In the merge-tool: jump to the next conflict" },
                },
                {
                    "n",
                    "<leader>co",
                    actions.conflict_choose "ours",
                    { desc = "Choose the OURS version of a conflict" },
                },
                {
                    "n",
                    "<leader>ct",
                    actions.conflict_choose "theirs",
                    { desc = "Choose the THEIRS version of a conflict" },
                },
                {
                    "n",
                    "<leader>cb",
                    actions.conflict_choose "base",
                    { desc = "Choose the BASE version of a conflict" },
                },
                {
                    "n",
                    "<leader>ca",
                    actions.conflict_choose "all",
                    { desc = "Choose all the versions of a conflict" },
                },
                { "n", "dx", actions.conflict_choose "none", { desc = "Delete the conflict region" } },
                {
                    "n",
                    "<leader>cO",
                    actions.conflict_choose_all "ours",
                    { desc = "Choose the OURS version of a conflict for the whole file" },
                },
                {
                    "n",
                    "<leader>cT",
                    actions.conflict_choose_all "theirs",
                    { desc = "Choose the THEIRS version of a conflict for the whole file" },
                },
                {
                    "n",
                    "<leader>cB",
                    actions.conflict_choose_all "base",
                    { desc = "Choose the BASE version of a conflict for the whole file" },
                },
                {
                    "n",
                    "<leader>cA",
                    actions.conflict_choose_all "all",
                    { desc = "Choose all the versions of a conflict for the whole file" },
                },
                {
                    "n",
                    "dX",
                    actions.conflict_choose_all "none",
                    { desc = "Delete the conflict region for the whole file" },
                },
            },
            diff1 = {
                -- Mappings in single window diff layouts
                { "n", "g?", actions.help { "view", "diff1" }, { desc = "Open the help panel" } },
            },
            diff2 = {
                -- Mappings in 2-way diff layouts
                { "n", "g?", actions.help { "view", "diff2" }, { desc = "Open the help panel" } },
            },
            diff3 = {
                -- Mappings in 3-way diff layouts
                {
                    { "n", "x" },
                    "2do",
                    actions.diffget "ours",
                    { desc = "Obtain the diff hunk from the OURS version of the file" },
                },
                {
                    { "n", "x" },
                    "3do",
                    actions.diffget "theirs",
                    { desc = "Obtain the diff hunk from the THEIRS version of the file" },
                },
                { "n", "g?", actions.help { "view", "diff3" }, { desc = "Open the help panel" } },
            },
            diff4 = {
                -- Mappings in 4-way diff layouts
                {
                    { "n", "x" },
                    "1do",
                    actions.diffget "base",
                    { desc = "Obtain the diff hunk from the BASE version of the file" },
                },
                {
                    { "n", "x" },
                    "2do",
                    actions.diffget "ours",
                    { desc = "Obtain the diff hunk from the OURS version of the file" },
                },
                {
                    { "n", "x" },
                    "3do",
                    actions.diffget "theirs",
                    { desc = "Obtain the diff hunk from the THEIRS version of the file" },
                },
                { "n", "g?", actions.help { "view", "diff4" }, { desc = "Open the help panel" } },
            },
            file_panel = {
                {
                    "n",
                    "j",
                    actions.next_entry,
                    { desc = "Bring the cursor to the next file entry" },
                },
                {
                    "n",
                    "<down>",
                    actions.next_entry,
                    { desc = "Bring the cursor to the next file entry" },
                },
                {
                    "n",
                    "k",
                    actions.prev_entry,
                    { desc = "Bring the cursor to the previous file entry" },
                },
                {
                    "n",
                    "<up>",
                    actions.prev_entry,
                    { desc = "Bring the cursor to the previous file entry" },
                },
                {
                    "n",
                    "<cr>",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "o",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "l",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "<2-LeftMouse>",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "-",
                    actions.toggle_stage_entry,
                    { desc = "Stage / unstage the selected entry" },
                },
                {
                    "n",
                    "s",
                    actions.toggle_stage_entry,
                    { desc = "Stage / unstage the selected entry" },
                },
                { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
                { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
                {
                    "n",
                    "X",
                    actions.restore_entry,
                    { desc = "Restore entry to the state on the left side" },
                },
                {
                    "n",
                    "L",
                    actions.open_commit_log,
                    { desc = "Open the commit log panel" },
                },
                { "n", "zo", actions.open_fold, { desc = "Expand fold" } },
                { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
                { "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
                { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
                { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
                { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
                { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
                {
                    "n",
                    "<tab>",
                    actions.select_next_entry,
                    { desc = "Open the diff for the next file" },
                },
                {
                    "n",
                    "<s-tab>",
                    actions.select_prev_entry,
                    { desc = "Open the diff for the previous file" },
                },
                {
                    "n",
                    "[F",
                    actions.select_first_entry,
                    { desc = "Open the diff for the first file" },
                },
                {
                    "n",
                    "]F",
                    actions.select_last_entry,
                    { desc = "Open the diff for the last file" },
                },
                {
                    "n",
                    "gf",
                    actions.goto_file_edit,
                    { desc = "Open the file in the previous tabpage" },
                },
                {
                    "n",
                    "<C-w><C-f>",
                    actions.goto_file_split,
                    { desc = "Open the file in a new split" },
                },
                {
                    "n",
                    "<C-w>gf",
                    actions.goto_file_tab,
                    { desc = "Open the file in a new tabpage" },
                },
                {
                    "n",
                    "i",
                    actions.listing_style,
                    { desc = "Toggle between 'list' and 'tree' views" },
                },
                {
                    "n",
                    "f",
                    actions.toggle_flatten_dirs,
                    { desc = "Flatten empty subdirectories in tree listing style" },
                },
                {
                    "n",
                    "R",
                    actions.refresh_files,
                    { desc = "Update stats and entries in the file list" },
                },
                {
                    "n",
                    "<leader>e",
                    actions.focus_files,
                    { desc = "Bring focus to the file panel" },
                },
                { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
                { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
                {
                    "n",
                    "[x",
                    actions.prev_conflict,
                    { desc = "Go to the previous conflict" },
                },
                { "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
                { "n", "g?", actions.help "file_panel", { desc = "Open the help panel" } },
                {
                    "n",
                    "<leader>cO",
                    actions.conflict_choose_all "ours",
                    { desc = "Choose the OURS version of a conflict for the whole file" },
                },
                {
                    "n",
                    "<leader>cT",
                    actions.conflict_choose_all "theirs",
                    { desc = "Choose the THEIRS version of a conflict for the whole file" },
                },
                {
                    "n",
                    "<leader>cB",
                    actions.conflict_choose_all "base",
                    { desc = "Choose the BASE version of a conflict for the whole file" },
                },
                {
                    "n",
                    "<leader>cA",
                    actions.conflict_choose_all "all",
                    { desc = "Choose all the versions of a conflict for the whole file" },
                },
                {
                    "n",
                    "dX",
                    actions.conflict_choose_all "none",
                    { desc = "Delete the conflict region for the whole file" },
                },
            },
            file_history_panel = {
                { "n", "g!", actions.options, { desc = "Open the option panel" } },
                {
                    "n",
                    "<C-A-d>",
                    actions.open_in_diffview,
                    { desc = "Open the entry under the cursor in a diffview" },
                },
                {
                    "n",
                    "y",
                    actions.copy_hash,
                    { desc = "Copy the commit hash of the entry under the cursor" },
                },
                { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
                {
                    "n",
                    "X",
                    actions.restore_entry,
                    { desc = "Restore file to the state from the selected entry" },
                },
                { "n", "zo", actions.open_fold, { desc = "Expand fold" } },
                { "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
                { "n", "h", actions.close_fold, { desc = "Collapse fold" } },
                { "n", "za", actions.toggle_fold, { desc = "Toggle fold" } },
                { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
                { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
                {
                    "n",
                    "j",
                    actions.next_entry,
                    { desc = "Bring the cursor to the next file entry" },
                },
                {
                    "n",
                    "<down>",
                    actions.next_entry,
                    { desc = "Bring the cursor to the next file entry" },
                },
                {
                    "n",
                    "k",
                    actions.prev_entry,
                    { desc = "Bring the cursor to the previous file entry" },
                },
                {
                    "n",
                    "<up>",
                    actions.prev_entry,
                    { desc = "Bring the cursor to the previous file entry" },
                },
                {
                    "n",
                    "<cr>",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "o",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "l",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                {
                    "n",
                    "<2-LeftMouse>",
                    actions.select_entry,
                    { desc = "Open the diff for the selected entry" },
                },
                { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
                { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
                {
                    "n",
                    "<tab>",
                    actions.select_next_entry,
                    { desc = "Open the diff for the next file" },
                },
                {
                    "n",
                    "<s-tab>",
                    actions.select_prev_entry,
                    { desc = "Open the diff for the previous file" },
                },
                {
                    "n",
                    "[F",
                    actions.select_first_entry,
                    { desc = "Open the diff for the first file" },
                },
                {
                    "n",
                    "]F",
                    actions.select_last_entry,
                    { desc = "Open the diff for the last file" },
                },
                {
                    "n",
                    "gf",
                    actions.goto_file_edit,
                    { desc = "Open the file in the previous tabpage" },
                },
                {
                    "n",
                    "<C-w><C-f>",
                    actions.goto_file_split,
                    { desc = "Open the file in a new split" },
                },
                {
                    "n",
                    "<C-w>gf",
                    actions.goto_file_tab,
                    { desc = "Open the file in a new tabpage" },
                },
                {
                    "n",
                    "<leader>e",
                    actions.focus_files,
                    { desc = "Bring focus to the file panel" },
                },
                { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
                { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
                { "n", "g?", actions.help "file_history_panel", { desc = "Open the help panel" } },
            },
            option_panel = {
                { "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
                { "n", "q", actions.close, { desc = "Close the panel" } },
                { "n", "g?", actions.help "option_panel", { desc = "Open the help panel" } },
            },
            help_panel = {
                { "n", "q", actions.close, { desc = "Close help menu" } },
                { "n", "<esc>", actions.close, { desc = "Close help menu" } },
            },
        },
    }

    require("illuminate").configure {}

    require("smartcolumn").setup()

    vim.schedule(function()
        require "mappings"
    end)
end
