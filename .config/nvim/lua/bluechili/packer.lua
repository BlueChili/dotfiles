-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    })

    use('folke/tokyonight.nvim')

    use('luisiacc/gruvbox-baby')
    use('morhetz/gruvbox')
    use('kenwheeler/glow-in-the-dark-gucci-shark-bites-vim')

    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
    use('tpope/vim-fugitive')
    use('tpope/vim-surround')
    use('tpope/vim-repeat')
    use('tpope/vim-sleuth')
    use('tpope/vim-commentary')
    use('mbbill/undotree')

    use('mattn/emmet-vim')

    use('prettier/vim-prettier')

    use('wuelnerdotexe/vim-astro')

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        }
    }


end)
