local opt = vim.opt

-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- backup
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

-- search
opt.hlsearch = false
opt.incsearch = true

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- appearance (does not work)
opt.termguicolors = true
-- opt.background = "light"

-- scroll
opt.scrolloff = 8

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
-- opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

-- fix comment issue (does not work)
-- vim.cmd('set formatoptions-=cro')

vim.opt.updatetime = 50
