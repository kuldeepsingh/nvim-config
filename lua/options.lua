require "nvchad.options"

vim.opt.cursorlineopt = "both" -- to enable cursorline!

-- Indenting
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number = true
vim.opt.cursorcolumn = true
-- disable netrw at the very start of your init.lua
--  optionally enable 24-bit colour
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = "%s %l %r "
vim.opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.laststatus = 3
vim.opt.clipboard = "unnamedplus"

vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 1
vim.opt.foldenable = true
vim.o.completeopt = "menuone,noselect"
vim.opt_local.spell = true

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- auto close brackets
-- this
vim.api.nvim_create_autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- show cursor line only in active window
local cursorGrp = vim.api.nvim_create_augroup("CursorLine", { clear = true })
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    pattern = "*",
    command = "set cursorline",
    group = cursorGrp,
})
vim.api.nvim_create_autocmd(
    { "InsertEnter", "WinLeave" },
    { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- Enable spell checking for certain file types
vim.api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    -- { pattern = { "*.txt", "*.md", "*.tex" }, command = [[setlocal spell<cr> setlocal spelllang=en,de<cr>]] }
    {
        pattern = { "*.txt", "*.md", "*.tex" },
        callback = function()
            vim.opt.spelllang = "en_us"
            vim.opt.spell = true
        end,
    }
)

-- don't auto comment new line
vim.api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.cmd "highlight Winbar guibg=none"
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- resize neovim split when terminal is resized
vim.api.nvim_command "autocmd VimResized * wincmd ="

-- fix terraform and hcl comment string
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("FixTerraformCommentString", { clear = true }),
    callback = function(ev)
        vim.bo[ev.buf].commentstring = "# %s"
    end,
    pattern = { "terraform", "hcl" },
})

-- -- Golang format on save
local goformat_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        require("go.format").gofmt()
    end,
    group = goformat_sync_grp,
})
--
-- Run gofmt + goimport on save
local goimport_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        require("go.format").goimport()
    end,
    group = goimport_sync_grp,
})

-------------------------------------------------------------------------------
--- Display diagnos analysis
--- Display hide or show the code analysis
-------------------------------------------------------------------------------
local function hide_diagnostics()
    vim.diagnostic.config { -- https://neovim.io/doc/user/diagnostic.html
        virtual_text = false,
        signs = false,
        underline = false,
    }
end

local function show_diagnostics()
    vim.diagnostic.config {
        virtual_text = true,
        signs = true,
        underline = true,
    }
end
vim.keymap.set("n", "<leader>kh", hide_diagnostics, { desc = "Hide the diagostics" })
vim.keymap.set("n", "<leader>kg", show_diagnostics, { desc = "Show the diagostics" })

--- Disabling the diagnosis by default
vim.diagnostic.config { -- https://neovim.io/doc/user/diagnostic.html
    virtual_text = false,
    signs = false,
    underline = false,
}

vim.cmd [[ autocmd BufEnter * silent! lcd %:p:h ]]

--- Auto building of cscope.sb on write for the project
-- local group = vim.api.nvim_create_augroup("CscopeBuild", { clear = true })
-- vim.api.nvim_create_autocmd("BufWritePost", {
-- pattern = { "*.cpp", "*.c", "*.h", "*.S" },
-- callback = function()
-- vim.cmd "Cscope db build"
-- end,
-- group = group,
-- })

-- undo tree
vim.keymap.set("n", "undo", "<cmd>Telescope undo<cr>")

-- Toggle maximizing the current window:
vim.keymap.set("n", "<Leader>az", "<Cmd>lua require('maximize').toggle()<CR>")
