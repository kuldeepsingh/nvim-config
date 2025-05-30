if vim.g.vscode then
    -- VSCode Neovim
    require "user.vscode_keymaps"
else
    -- Ordinary Neovim
    local vim = vim
    local Plug = vim.fn["plug#"]

    ---------------------------------------------------------------------------
    --- LSP install
    ---------------------------------------------------------------------------
    vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
    vim.g.mapleader = " "

    ---------------------------------------------------------------------------
    -- bootstrap lazy and all plugins
    ---------------------------------------------------------------------------
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

    require "nvchad.autocmds"
    require "options"
    require "mappings"
    ---------------------------------------------------------------------------
    require("java").setup()
    --require("lspconfig").jdtls.setup {}
    ---------------------------------------------------------------------------
    -- Set up nvim-cmp.
    ---------------------------------------------------------------------------
    local on_attach = function(_, _)
        local keyset = vim.keymap.set
        keyset("n", "<leader>rn", vim.lsp.buf.rename, {}) -- rename
        keyset("n", "<leader>ca", vim.lsp.buf.code_action, {}) -- code action
        keyset("n", "gd", vim.lsp.buf.definition, {}) -- global definition
        keyset("n", "gi", vim.lsp.buf.implementation, {}) -- global implementation
        keyset("n", "gr", require("telescope.builtin").lsp_references, {}) -- global references
        keyset("n", "K", vim.lsp.buf.hover, {}) -- global implementation
    end

    local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

    -- Setup all of the LSPs
    require("lspconfig").lua_ls.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").gopls.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").rust_analyzer.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").texlab.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").marksman.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").html.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").cssls.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").ts_ls.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").bashls.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").hls.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").tailwindcss.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").asm_lsp.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").pyright.setup { on_attach = on_attach, capabilities = capabilities }
    require("lspconfig").clangd.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
            "clangd",
            "--offset-encoding=utf-16",
            "--background-index",
            "--suggest-missing-includes",
            "--clang-tidy",
            -- "--compile-commands-dir=/home/localuser/test/build",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "h", "hh", "cc" },
        init_options = {},
    }

    require("mason-lspconfig").setup {
        ensure_installed = {
            "lua_ls", -- Lua
            "rust_analyzer", -- Rust
            "clangd", -- C/C++
            "texlab", -- LaTeX
            "marksman", -- Markdown
            "html", -- HTML
            "cssls",
            "ts_ls", -- JS/TypeScript
            "bashls", -- Bash
            "pyright", --Python
            "taplo", --toml
            "gopls", -- Go language
        },
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- load theme
    ---------------------------------------------------------------------------
    dofile(vim.g.base46_cache .. "defaults")
    dofile(vim.g.base46_cache .. "statusline")
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Save and restore the sessions
    --- FIXME : how to control saving or not-saving config
    ---------------------------------------------------------------------------
    require("auto-session").setup {}
    ---------------------------------------------------------------------------

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
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Find Keymaps" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
    vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search Git Commits" })
    vim.keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "Search Git Commits for Buffer" })
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

    require("telescope").load_extension "advanced_git_search"
    require("telescope").load_extension "noice"
    require("telescope").load_extension "fzf"
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- FIXME check what is this
    ---------------------------------------------------------------------------
    require("img-clip").setup {}
    require("render-markdown").setup {}

    ---------------------------------------------------------------------------
    -- AI setup
    ---------------------------------------------------------------------------
    -- require("copilot").setup {}
    -- require("avante_lib").load()
    -- require("avante").setup {}
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Debugging setup for Python
    ---------------------------------------------------------------------------
    require("dap-python").setup("~/learning/coding/python/.venv//bin/python", {
        include_configs = true,
        console = "integratedTerminal",
        pythonPath = nil,
    })

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

    vim.keymap.set("n", "<leader>dl", require("dap").close, { desc = "Stop" })
    vim.keymap.set("n", "<Leader>dt", require("dapui").toggle, { desc = "Toggle Dap UI" })

    local dap, dapui = require "dap", require "dapui"
    dapui.setup()

    -- open Dap UI automatically when debug starts (e.g. after <F5>)
    dap.listeners.before.attach.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
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
            name = "Launch file with arguments (justMyCode = false)",
            type = "codelldb",
            request = "launch",
            program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            justMyCode = false,
            args = function()
                local args_string = vim.fn.input "Arguments: "
                return vim.split(args_string, " +")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            runInTerminal = true,
        },
    }

    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Symbol outline
    ---------------------------------------------------------------------------
    local opts = {
        highlight_hovered_item = true,
        show_guides = true,
        auto_preview = false,
        position = "right",
        relative_width = true,
        show_numbers = true,
        show_relative_numbers = true,
        show_symbol_details = true,
        autofold_depth = nil,
        auto_unfold_hover = true,
    }
    require("symbols-outline").setup(opts)
    vim.keymap.set("n", "sym", "<cmd>SymbolsOutline<CR>", { desc = "Toggle the symbol outline" })
    vim.keymap.set("n", "<leader>ts", "<cmd>SymbolsOutline<CR>", { desc = "Toggle the symbol outline" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Terminal App
    ---------------------------------------------------------------------------
    require("toggleterm").setup {
        persist_mode = false,
        direction = "horizontal",
        start_in_insert = true,
        ---float_opts = {
        ---    --border = "double" | "shadow" | "curved",
        ---    border = "double",
        ---},
    }
    vim.keymap.set("n", "ter", "<cmd>ToggleTerm<CR>", { desc = "Toggle the terminal" })
    vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle the terminal" })
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Noice notices
    ---------------------------------------------------------------------------
    require("noice").setup {
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
            signature = {
                enabled = false,
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
        cmdline = {
            enabled = true, -- enables the Noice cmdline UI
            view = "cmdline_popup",
            --view = "cmdline_popup",
        },
    }

    vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
    vim.api.nvim_set_keymap("c", "<Up>", 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })

    function _G.get_wildmenu_key(key_wildmenu, key_regular)
        return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
    end
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- FIXME : Need to check, what this does ?
    --- A simple way to run and visualize code actions with Telescope.
    ----------------------------------------------------------------------------
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

    ---------------------------------------------------------------------------
    --- Fast scrolling
    ---------------------------------------------------------------------------
    require("neoscroll").setup {
        mappings = { -- Keys to be mapped to their corresponding default scrolling animation
            "<C-b>",
            "<C-f>",
        },
        hide_cursor = true, -- Hide cursor while scrolling
        stop_eof = true, -- Stop at <EOF> when scrolling downwards
        respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        duration_multiplier = 1.0, -- Global duration multiplier
        easing = "circular", -- Default easing function
        pre_hook = nil, -- Function to run before the scrolling animation starts
        post_hook = nil, -- Function to run after the scrolling animation ends
        performance_mode = false, -- Disable "Performance Mode" on all buffers.
        ignored_events = { -- Events ignored while scrolling
            "WinScrolled",
            "CursorMoved",
        },
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Diffview
    --- FIXME : Need to check for the default mappings and setuu
    ---------------------------------------------------------------------------
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

    ---------------------------------------------------------------------------
    --- Display underline all the words appearance as under cursor
    ---------------------------------------------------------------------------
    require("illuminate").configure {}
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Display column intellegently of column exceeds 80 char
    ---------------------------------------------------------------------------
    require("smartcolumn").setup()
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Display the key pressed on top right corner
    ---------------------------------------------------------------------------
    require("showkeys").open()
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Display the action-hint for the code to the lua line
    ---------------------------------------------------------------------------
    require("lualine").setup {
        options = {
            theme = "auto",
        },
        sections = {
            lualine_a = {
                "mode",
                { "ex.lsp.all", only_attached = false, notify_enabled = true, notify_hl = "Comment" },
            },
            lualine_b = { "diff", "diagnostics" },
            lualine_c = { { "filename", path = 1 } },
            lualine_x = {
                { "fileformat", "filetype" },
                { require("action-hints").statusline },
                {
                    require("noice").api.statusline.mode.get,
                    cond = require("noice").api.statusline.mode.has,
                    color = { fg = "#ff9e64" },
                },
            },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
        extensions = { "fugitive", "quickfix", "fzf", "lazy", "mason", "nvim-dap-ui", "oil", "trouble" },
    }

    require("fzf-lua").setup { "fzf-native" }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---  highlight lines
    ---------------------------------------------------------------------------
    require("colorizer").setup {
        filetypes = {
            "*", -- Highlight all files, but customize some others.
        },
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---  Autotagging HTML Tags
    ---------------------------------------------------------------------------
    require("nvim-ts-autotag").setup {
        opts = {
            enable_close = true, -- Auto close tags
            enable_rename = true, -- Auto rename pairs of tags
            enable_close_on_slash = false, -- Auto close on trailing </
        },
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Custom command to update the mason
    ---------------------------------------------------------------------------
    require("mason-update-all").setup()
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Lua line Config
    ---------------------------------------------------------------------------
    vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
    vim.api.nvim_create_autocmd("User", {
        group = "lualine_augroup",
        pattern = "LspProgressStatusUpdated",
        callback = require("lualine").refresh,
    })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Lazygit Config
    ---------------------------------------------------------------------------
    require("telescope").load_extension "lazygit"
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Signature help config
    --- FIXME : Check if this is even working
    ---------------------------------------------------------------------------
    local cfg = {
        bind = true,
        handler_opts = { border = "rounded" },
        floating_window_off_x = 5, -- adjust float windows x position.
        floating_window_off_y = function()
            local linenr = vim.api.nvim_win_get_cursor(0)[1] -- buf line number
            local pumheight = vim.o.pumheight
            local winline = vim.fn.winline() -- line number in the window
            local winheight = vim.fn.winheight(0)

            -- window top
            if winline - 1 < pumheight then
                return pumheight
            end

            -- window bottom
            if winheight - winline < pumheight then
                return -pumheight
            end
            return 0
        end,
    }
    --require("lsp_signature").setup(cfg)
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Cscope map : Still needs to be configured
    --- FIXME : check this to set the multiple cscope DB
    ---------------------------------------------------------------------------
    require("cscope_maps").setup {
        cscope = {
            db_file = { "cscope.out" },
            use_telescope = true,
            picker = "telescope",
            skip_picker_for_single_result = true,
            db_build_cmd = { script = "none", args = { "-bgR" } },
            project_rooter = {
                enable = true, -- “true” or "false"
                change_cwd = true, -- “true” or “false”
            },
        },
    }
    -- 's'   symbol: find all references to the token under cursor
    -- 'g'   global: find global definition(s) of the token under cursor
    -- 'c'   calls:  find all calls to the function name under cursor
    -- 't'   text:   find all instances of the text under cursor
    -- 'e'   egrep:  egrep search for the word under cursor
    -- 'f'   file:   open the filename under cursor
    -- 'i'   includes: find files that include the filename under cursor
    -- 'd'   called: find functions that function under cursor calls
    vim.keymap.set({ "n", "v" }, "cgs", "<cmd>Cs f s<cr>")
    vim.keymap.set({ "n", "v" }, "cgg", "<cmd>Cs f g<cr>")
    vim.keymap.set({ "n", "v" }, "cgc", "<cmd>Cs f c<cr>")
    vim.keymap.set({ "n", "v" }, "cgt", "<cmd>Cs f t<cr>")
    vim.keymap.set({ "n", "v" }, "cge", "<cmd>Cs f e<cr>")
    vim.keymap.set({ "n", "v" }, "cgf", "<cmd>Cs f f<cr>")
    vim.keymap.set({ "n", "v" }, "cgi", "<cmd>Cs f i<cr>")
    vim.keymap.set({ "n", "v" }, "cgd", "<cmd>Cs f d<cr>")

    vim.api.nvim_create_user_command("TT", function(opts)
        vim.cmd("Cstag " .. opts.args)
    end, { nargs = 1 })

    local function get_project_root()
        local dot_root_path = vim.fn.finddir(".root", ".;")
        local path_local = vim.fn.fnamemodify(dot_root_path, ":h")
        return path_local
    end

    local group = vim.api.nvim_create_augroup("CscopeBuild", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.hh", "*hpp", "*.c", "*.h", "*.cc", "*.cpp", "*.s", "*.S" },
        callback = function()
            vim.api.nvim_set_current_dir(get_project_root())
            vim.cmd "Cscope db build"
        end,
        group = group,
    })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Suggestion and autoCompletion
    ---------------------------------------------------------------------------
    require("cmp.config.context").in_treesitter_capture "spell"

    ---  Drop down list for the search in the cmdline setup.
    local cmp = require "cmp"
    cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer", { name = "dictionary", keyword_length = 2 } },
        },
        completeopt = "menu,menuone,noinsert",
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            {
                name = "cmdline",
                option = {
                    ignore_cmds = { "Man", "!" },
                },
            },
        }),
        completeopt = "menu,menuone,noinsert",
    })

    cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
            { name = "git" },
        }, {
            { name = "buffer" },
        }),
    })
    ----------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- Luasnip config
    ---------------------------------------------------------------------------
    local ls = require "luasnip"

    vim.keymap.set({ "i" }, "<C-K>", function()
        ls.expand()
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-L>", function()
        ls.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-J>", function()
        ls.jump(-1)
    end, { silent = true })

    vim.keymap.set({ "i", "s" }, "<C-E>", function()
        if ls.choice_active() then
            ls.change_choice(1)
        end
    end, { silent = true })

    require("luasnip.loaders.from_vscode").lazy_load()

    ---------------------------------------------------------------------------
    -- FIXME :
    ---------------------------------------------------------------------------
    require("cmp").setup {
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        sources = {
            { name = "nvim_lsp" },
            { name = "buffer" },
            {
                name = "dictionary",
                keyword_length = 2,
            },
        },
        mapping = cmp.mapping.preset.insert {
            ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
            ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
            },
        },
    }

    ---------------------------------------------------------------------------
    --- Dictionary setup for the md and txt files
    ---------------------------------------------------------------------------
    require("cmp_dictionary").setup {
        paths = { "/usr/share/dict/words" },
        exact_length = 2,
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- telescope based  Diff for 2 files
    ---------------------------------------------------------------------------
    require("telescope").load_extension "diff"
    vim.keymap.set("n", "<leader>d2", function()
        require("telescope").extensions.diff.diff_files { hidden = true }
    end, { desc = "Compare 2 files" })
    vim.keymap.set("n", "<leader>d1", function()
        require("telescope").extensions.diff.diff_current { hidden = true }
    end, { desc = "Compare file with current" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Zen mode : use 'zen' command in normal mode
    ---------------------------------------------------------------------------
    vim.keymap.set("n", "zen", function()
        require("focus").toggle_zen {
            zen = {
                opts = {
                    number = true, -- enable number column
                    relativenumber = true, -- enable relative numbers
                    statuscolumn = "%=%{v:relnum?v:relnum:v:lnum} ", -- enable statuscolumn with specific configuration
                },
            },
        }
    end, { desc = "Toggle Zen Mode" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Dimming of non-effective code. Use 'dim' command in normal mode
    ---------------------------------------------------------------------------
    require("twilight.config").setup {}
    vim.keymap.set("n", "dim", "<cmd>Twilight<CR>", { desc = "Toggle Twilight mode" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---- Qucker list using <C-t>
    ---------------------------------------------------------------------------
    require("trouble").setup { focus = false }
    local actions = require "telescope.actions"
    local open_with_trouble = require("trouble.sources.telescope").open

    -- Use this to add more results without clearing the trouble list
    local add_to_trouble = require("trouble.sources.telescope").add

    local telescope = require "telescope"

    telescope.setup {
        defaults = {
            mappings = {
                i = { ["<c-t>"] = open_with_trouble },
                n = { ["<c-t>"] = open_with_trouble },
            },
        },
    }
    local config = require "fzf-lua.config"
    local actions = require("trouble.sources.fzf").actions

    vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        callback = function()
            vim.cmd [[Trouble qflist open]]
        end,
    })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    -- This module contains a number of default definitions
    ---------------------------------------------------------------------------
    local rainbow_delimiters = require "rainbow-delimiters"

    ---@type rainbow_delimiters.config
    vim.g.rainbow_delimiters = {
        strategy = {
            [""] = rainbow_delimiters.strategy["global"],
            vim = rainbow_delimiters.strategy["local"],
        },
        query = {
            [""] = "rainbow-delimiters",
            lua = "rainbow-blocks",
        },
        priority = {
            [""] = 110,
            lua = 210,
        },
        highlight = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterBlue",
            "RainbowDelimiterOrange",
            "RainbowDelimiterGreen",
            "RainbowDelimiterViolet",
            "RainbowDelimiterCyan",
        },
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- LSP diagnostic list
    --- global lsp mappings
    ---------------------------------------------------------------------------
    vim.keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Maximize the split window using "<leader>z"
    ---------------------------------------------------------------------------
    require("maximizer").setup {}
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---  LSP Progress
    ---------------------------------------------------------------------------
    require("lsp-progress").setup {
        decay = 1200,
        series_format = function(title, message, percentage, done)
            local builder = {}
            local has_title = false
            local has_message = false
            if type(title) == "string" and string.len(title) > 0 then
                table.insert(builder, title)
                has_title = true
            end
            if type(message) == "string" and string.len(message) > 0 then
                table.insert(builder, message)
                has_message = true
            end
            if percentage and (has_title or has_message) then
                table.insert(builder, string.format("(%.0f%%)", percentage))
            end
            return { msg = table.concat(builder, " "), done = done }
        end,
        client_format = function(client_name, spinner, series_messages)
            if #series_messages == 0 then
                return nil
            end
            local builder = {}
            local done = true
            for _, series in ipairs(series_messages) do
                if not series.done then
                    done = false
                end
                table.insert(builder, series.msg)
            end
            if done then
                spinner = "✓" -- replace your check mark
            end
            return "[" .. client_name .. "] " .. spinner .. " " .. table.concat(builder, ", ")
        end,
    }
    ---------------------------------------------------------------------------

    require("telescope").load_extension "fidget"

    ---------------------------------------------------------------------------
    --- Symbol Outline
    ---------------------------------------------------------------------------
    require("outline").setup {}
    vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- function header documentation
    ---------------------------------------------------------------------------
    require("codedocs").setup {
        default_styles = { python = "reST" },
    }
    vim.keymap.set("n", "<leader>kc", require("codedocs").insert_docs, { desc = "Insert docstring" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- code running from Neovim
    ---------------------------------------------------------------------------
    require("runner").setup {
        position = "bottom", -- position of the terminal window when using the shell_handler
        -- can be: top, left, right, bottom
        -- will be overwritten when using the telescope mapping to open horizontally or vertically

        width = 80, -- width of window when position is left or right
        height = 10, -- height of window when position is top or bottom

        handlers = {}, -- discussed in the next section
    }
    vim.keymap.set("n", "<leader><space>", require("runner").run, { desc = "Run the program" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- code running from Neovim
    ---------------------------------------------------------------------------
    require("interestingwords").setup {
        colors = { "#ffaa11", "#a21100", "#d140ff", "#b88823", "#ffa2f4", "#6f2cff" },
        search_count = true,
        navigation = true,
        scroll_center = true,
        search_key = "<leader>m",
        cancel_search_key = "<leader>M",
        color_key = "<leader>k",
        cancel_color_key = "<leader>K",
        select_mode = "loop", -- random or loop
    }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---  Transpose the windows
    ---  FIXME : Currently it is not working
    ---------------------------------------------------------------------------
    vim.keymap.set("n", "<C-w><C-t>", "<Cmd>VentanaTranspose<CR>", { desc = "Transpose windows" })
    vim.keymap.set("n", "<C-w><C-f>", "<Cmd>VentanaShift<CR>")
    vim.keymap.set("n", "<C-w>f", "<Cmd>VentanaShiftMaintainLinear<CR>")
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---  Open Link  using "link"
    ---------------------------------------------------------------------------
    require("url-open").setup()
    vim.keymap.set("n", "gx", "<esc>:URLOpenUnderCursor<cr>", { desc = "Open the web link" })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---  Open the Leet code in nvim, using "nvim leetcode.nvim" command
    ---------------------------------------------------------------------------
    --require("leetcode").setup { lang = "python3" }
    require("leetcode").setup { lang = "c" }
    --require("leetcode").setup { lang = "cpp" }
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Track of the config files for nvim modifications in days
    ---------------------------------------------------------------------------
    require("ohne-accidents").setup {
        welcomeOnStartup = true,
        api = "notify",
        multiLine = false,
    }
    vim.api.nvim_set_keymap("n", "<leader>oh", ":OhneAccidents<CR>", { noremap = true, silent = true })
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    --- Neorg
    ---------------------------------------------------------------------------
    require("neorg").setup {
        load = {
            ["core.defaults"] = {},
            ["core.concealer"] = {}, -- We added this line!
        },
    }

    ---------------------------------------------------------------------------
    --- Neovide font resize
    ---------------------------------------------------------------------------
    options = {
        default_size = 11, -- absolute size it will fallback to when :GUIFontSizeSet is not specified
        change_by = 1, -- step value that will inc/dec the fontsize by
        bounds = {
            maximum = 24, -- maximum font size, when you try to set a size bigger than this it will default to max
            minimum = 8, -- any modification lower than 8 will spring back to 8
        },
    }

    require("gui-font-resize").setup { default_size = 10, change_by = 1, bounds = { maximum = 20 } }

    require("wrapping").soft_wrap_mode()

    local iron = require "iron.core"
    local view = require "iron.view"
    local common = require "iron.fts.common"

    iron.setup {
        config = {
            -- Whether a repl should be discarded or not
            scratch_repl = true,
            -- Your repl definitions come here
            repl_definition = {
                sh = {
                    -- Can be a table or a function that
                    -- returns a table (see below)
                    command = { "zsh" },
                },
                python = {
                    command = { "python3" }, -- or { "ipython", "--no-autoindent" }
                    format = common.bracketed_paste_python,
                    block_dividers = { "# %%", "#%%" },
                },
            },
            -- set the file type of the newly created repl to ft
            -- bufnr is the buffer id of the REPL and ft is the filetype of the
            -- language being used for the REPL.
            repl_filetype = function(bufnr, ft)
                return ft
                -- or return a string name such as the following
                -- return "iron"
            end,
            -- How the repl window will be displayed
            -- See below for more information
            -- repl_open_cmd = view.bottom(40),

            -- repl_open_cmd can also be an array-style table so that multiple
            -- repl_open_commands can be given.
            -- When repl_open_cmd is given as a table, the first command given will
            -- be the command that `IronRepl` initially toggles.
            -- Moreover, when repl_open_cmd is a table, each key will automatically
            -- be available as a keymap (see `keymaps` below) with the names
            -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
            -- For example,
            --
            repl_open_cmd = {
                view.split.vertical.rightbelow "%40", -- cmd_1: open a repl to the right
                view.split.rightbelow "%25", -- cmd_2: open a repl below
            },
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
            toggle_repl = "<space>rr", -- toggles the repl open and closed.
            -- If repl_open_command is a table as above, then the following keymaps are
            -- available
            -- toggle_repl_with_cmd_1 = "<space>rv",
            -- toggle_repl_with_cmd_2 = "<space>rh",
            restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
            send_motion = "<space>sc",
            visual_send = "<space>sc",
            send_file = "<space>sf",
            send_line = "<space>sl",
            send_paragraph = "<space>sp",
            send_until_cursor = "<space>su",
            send_mark = "<space>sm",
            send_code_block = "<space>sb",
            send_code_block_and_move = "<space>sn",
            mark_motion = "<space>mc",
            mark_visual = "<space>mc",
            remove_mark = "<space>md",
            cr = "<space>s<cr>",
            interrupt = "<space>s<space>",
            exit = "<space>sq",
            clear = "<space>cl",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
            italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
    }

    -- iron also has a list of commands, see :h iron-commands for all available commands
    vim.keymap.set("n", "<space>rf", "<cmd>IronFocus<cr>")
    vim.keymap.set("n", "<space>rh", "<cmd>IronHide<cr>")
end
