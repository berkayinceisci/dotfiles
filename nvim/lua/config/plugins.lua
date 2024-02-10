local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end
]])

local status, packer = pcall(require, "packer")
if not status then
    return
end

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-tree/nvim-web-devicons'
    use 'nvim-tree/nvim-tree.lua'
    use 'christoomey/vim-tmux-navigator'
    use 'szw/vim-maximizer'
    use 'tpope/vim-fugitive'
    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    use 'tpope/vim-repeat'
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        'nvim-treesitter/nvim-treesitter-context',
        run = ':TSUpdate'
    }
    use 'theprimeagen/harpoon'
    use 'mbbill/undotree'
    use 'ggandor/leap.nvim'
    use {
        "akinsho/toggleterm.nvim",
        tag = '*'
    }

    -- fuzzy finding
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.2',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    -- color scheme
    use 'wincent/base16-nvim'
    use {
        'rose-pine/neovim',
        as = 'rose-pine'
    }
    use {
        "catppuccin/nvim",
        as = "catppuccin"
    }

    -- LSP Support
    use 'neovim/nvim-lspconfig'
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'

    -- Autocompletion
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        require('packer').sync()
    end
end)
