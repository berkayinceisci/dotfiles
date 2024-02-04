vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>ls", vim.cmd.Ex)

keymap.set("n", "<leader>sv", "<C-w>v")        -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s")        -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=")        -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>")    -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>")   -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>")     --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>")     --  go to previous tab

keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- stay in indent mode
keymap.set("v", "<", "<gv", { noremap = true, silent = true })
keymap.set("v", ">", ">gv", { noremap = true, silent = true })

keymap.set("n", "J", "mzJ`z")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "G", "Gzz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- replaces the selection with paste contents and keeps paste contents the same
keymap.set("x", "<leader>p", [["_dP]])

keymap.set({ "n", "v" }, "<leader>y", [["+y]])
keymap.set("n", "<leader>Y", [["+Y]])

keymap.set({ "n", "v" }, "<leader>d", [["+d]])

keymap.set("n", "Q", "<nop>")
-- keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
keymap.set("n", "<leader>fmt", vim.lsp.buf.format)

-- for quick list navigation
-- keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
keymap.set("n", "<leader>exe", "<cmd>!chmod +x %<CR>", { silent = true })

keymap.set("n", "<leader>cwd", [[:let @+=expand('%:p:h')<CR>]], { noremap = true, silent = true })

-- useful if nvimtree is used and therefore netrw is disabled
keymap.set("n", "gx", [[:silent execute '!open ' . shellescape(expand('<cfile>'), 1)<CR>]],
    { noremap = true, silent = true })

-- auto complete curly brackets
keymap.set("i", "{<CR>", "{<CR>}<Esc>O", { noremap = true })

-- make j and k move by visual line, not actual line, when text is soft-wrapped
keymap.set('n', 'j', 'gj')
keymap.set('n', 'k', 'gk')

-- let the left and right arrows be useful: they can switch buffers
vim.keymap.set('n', '<left>', ':bp<cr>zz')
vim.keymap.set('n', '<right>', ':bn<cr>zz')

-- "very magic" (less escaping needed) regexes by default
vim.keymap.set('n', '?', '?\\v')
vim.keymap.set('n', '/', '/\\v')
vim.keymap.set('c', '%s/', '%sm/')

-- <leader><leader> toggles between buffers
vim.keymap.set('n', '<leader><leader>', '<c-^>zz')

-- Jump to start and end of line using the home row keys
vim.keymap.set('', 'H', '^')
vim.keymap.set('', 'L', '$')

