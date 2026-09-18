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
--
-- Over ssh the default provider still picks xclip/wl-copy whenever DISPLAY is
-- set (the remote may have a real screen, and tmux/zsh keep DISPLAY alive), so
-- the yank lands on the REMOTE machine's clipboard, not the one we ssh'd from.
-- Key the choice on SSH_TTY instead of touching DISPLAY:
--   - inside tmux: the tmux provider (load-buffer -w) fills a tmux buffer and
--     tmux relays it via OSC 52 to whichever client is currently attached
--   - bare ssh:    emit OSC 52 straight to the terminal we ssh'd from
-- Local (non-ssh) sessions keep the default xclip/wl-copy/pbcopy detection.
if vim.env.SSH_TTY then
  vim.g.clipboard = vim.env.TMUX and "tmux" or "osc52"
end

-- split windows
opt.splitright = true
opt.splitbelow = true

-- fix comment issue
vim.cmd([[au BufEnter * set fo-=c fo-=r fo-=o]])

opt.updatetime = 50

opt.foldcolumn = "1" -- '0' is not bad
opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
opt.foldlevelstart = 99
opt.foldenable = true

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
