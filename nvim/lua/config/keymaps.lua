vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<leader>ls", vim.cmd.Ex)

keymap.set("n", "<leader>sv", "<C-w>v")        -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s")        -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=")        -- make split windows equal width & height
keymap.set("n", "<leader>sc", ":close<CR>")    -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>")   -- open new tab
keymap.set("n", "<leader>tc", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>")     -- go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>")     -- go to previous tab

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

-- copy contents to the system clipboard
keymap.set({ "n", "v" }, "<leader>y", [["+y]])
keymap.set("n", "<leader>Y", [["+Y]])
keymap.set({ "n", "v" }, "<leader>d", [["+d]])

keymap.set("n", "Q", "<nop>")
-- keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- for quick list navigation
-- keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- its advantage over F2 is that the changes are being shown on the screen, but F2 renames the variables on different files too
keymap.set("n", "<leader>cw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- copy the current working directory of the buffer to the clipboard (not works in ssh)
keymap.set("n", "<leader>cd", [[:let @+=expand('%:p:h')<CR>]], { noremap = true, silent = true })

-- make the current file executable (not that useful, the command itself is easy enough)
-- keymap.set("n", "<leader>exe", "<cmd>!chmod +x %<CR>", { silent = true })

-- useful if nvimtree is used and therefore netrw is disabled (opens link under the cursor in the browser)
keymap.set("n", "gx", [[:silent execute has ("mac") ? '!open ' : '!xdg-open ' . shellescape(expand('<cfile>'), 1)<CR>]],
    { noremap = true, silent = true })

-- auto complete curly brackets
keymap.set("i", "{<CR>", "{<CR>}<Esc>O", { noremap = true })

-- make j and k move by visual line, not actual line, when text is soft-wrapped
keymap.set('n', 'j', 'gj')
keymap.set('n', 'k', 'gk')

-- let the left and right arrows be useful: they can switch buffers
keymap.set('n', '<left>', ':bp<cr>zz')
keymap.set('n', '<right>', ':bn<cr>zz')

-- "very magic" (less escaping needed) regexes by default
keymap.set('n', '?', '?\\v')
keymap.set('n', '/', '/\\v')
keymap.set('c', '%s/', '%sm/')

-- toggles between buffers
keymap.set('n', '<leader><leader>', '<c-^>zz')

-- Jump to start and end of line using the home row keys
keymap.set('', 'H', '^')
keymap.set('', 'L', '$')

keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')
keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')
keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

-- If this is a script, make it executable, and execute it in a split pane on the right
-- Had to include quotes around "%" because there are some apple dirs that contain spaces, like iCloud
keymap.set("n", "<leader>./", function()
    local file = vim.fn.expand("%:p")                 -- Get the current file name
    local first_line = vim.fn.getline(1)              -- Get the first line of the file
    if string.match(first_line, "^#!/") then          -- If first line contains shebang
        local escaped_file = vim.fn.shellescape(file) -- Properly escape the file name for shell commands
        vim.cmd("!chmod +x " .. escaped_file)         -- Make the file executable
        vim.cmd("vsplit")                             -- Split the window vertically
        vim.cmd("terminal " .. escaped_file)          -- Open terminal and execute the file
        vim.cmd("startinsert")                        -- Enter insert mode, recommended by echasnovski on Reddit
    else
        vim.cmd("echo 'Not a script. Shebang line not found.'")
    end
end, { desc = "Execute current file in terminal (if it's a script)" })
