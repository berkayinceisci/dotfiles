return {
    "tpope/vim-surround",
    "tpope/vim-commentary",
    "tpope/vim-repeat",
    "folke/which-key.nvim",
    {
        "karb94/neoscroll.nvim",
        config = function()
            require('neoscroll').setup({
                mappings = { '<C-u>', '<C-d>', 'zz' }
            })
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require('colorizer').setup()
        end
    },
    {
        "szw/vim-maximizer",
        config = function()
            vim.keymap.set("n", "<leader>m", vim.cmd.MaximizerToggle)
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = "kevinhwang91/promise-async",
        config = function()
            require('ufo').setup()

            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        end
    },
    {
        "ggandor/leap.nvim",
        config = function()
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>w', '<Plug>(leap-forward)')
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>b', '<Plug>(leap-backward)')
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>W', '<Plug>(leap-from-window)')
        end
    }
}
