local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {}) -- project find
vim.keymap.set('n', '<leader>fs', function() 
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, {}) -- project search
