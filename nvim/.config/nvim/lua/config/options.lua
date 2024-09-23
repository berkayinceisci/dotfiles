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
opt.wrap = true
opt.linebreak = true

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

-- appearance
opt.termguicolors = true

-- scroll
opt.scrolloff = 8

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard (merge vim yank register with system clipboard)
-- opt.clipboard:append("unnamedplus")
-- instead, <leader> y is used to copy from vim into clipboard
-- and Ctrl Shift v to paste from system clipboard to vim buffer

-- split windows
opt.splitright = true
opt.splitbelow = true

-- fix comment issue
vim.cmd [[au BufEnter * set fo-=c fo-=r fo-=o]]

opt.updatetime = 50
