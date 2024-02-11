-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

require("nvim-tree").setup({
    sort_by = "case_sensitive",
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = false,
    },
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    actions = {
        open_file = {
            quit_on_open = true,
        },
    },
})

vim.keymap.set("n", "<leader>fe", ":NvimTreeToggle<CR>")
