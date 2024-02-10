require("toggleterm").setup {
    size = 20,
    open_mapping = [[<C-\>]],
    direction = "float",
    float_opts = {
        border = "curved",
    },
}

function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- open terminal in the current file directory
vim.keymap.set("n", "<leader>.f", '<CMD>TermExec cmd="cd %:p:h"<CR>', { noremap = true, silent = true })

-- open terminal in the current project root directory
vim.keymap.set("n", "<leader>.r", function()
    local command = 'TermExec cmd="cd ' .. vim.fn.getcwd() .. '"'
    vim.cmd("execute '" .. command .. "'")
end, { noremap = true, silent = true })

-- custom terminal integration
local Terminal  = require('toggleterm.terminal').Terminal

-- lazygit
local lazygit = Terminal:new({ cmd = "lazygit --use-config-dir ~/.config/lazygit", hidden = true })
function _LAZYGIT_TOGGLE()
  lazygit:toggle()
end
vim.keymap.set("n", "<leader>.g", "<cmd>lua _LAZYGIT_TOGGLE()<CR>", {noremap = true, silent = true})

-- htop
local htop = Terminal:new({ cmd = "htop", hidden = true })
function _HTOP_TOGGLE()
  htop:toggle()
end
vim.keymap.set("n", "<leader>.h", "<cmd>lua _HTOP_TOGGLE()<CR>", {noremap = true, silent = true})

