require('leap')

vim.keymap.set({ 'n', 'x', 'o' }, '<leader>w', '<Plug>(leap-forward)')
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>b', '<Plug>(leap-backward)')
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>W', '<Plug>(leap-from-window)')
