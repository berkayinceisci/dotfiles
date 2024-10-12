return {
    "tpope/vim-surround",
    "tpope/vim-commentary",
    "tpope/vim-repeat",
    "folke/which-key.nvim",
    {
        "anuvyklack/windows.nvim",
        dependencies = "anuvyklack/middleclass",
        config = function()
            require('windows').setup()
            vim.keymap.set('n', '<C-w>m', vim.cmd.WindowsMaximize)
            vim.cmd('WindowsDisableAutowidth')
        end
    },
    {
        "karb94/neoscroll.nvim",
        config = function()
            require('neoscroll').setup({
                mappings = { '<C-u>', '<C-d>' },
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
