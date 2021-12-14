-- https://github.com/wbthomason/packer.nvim

require "packer".startup(
  function(use)
    -- packer
    use "wbthomason/packer.nvim"

    -- library for multiple other plugins
    use "nvim-lua/plenary.nvim"

    -- theme and appearance
    use "EdenEast/nightfox.nvim"
    use "kyazdani42/nvim-web-devicons"
    use "hoob3rt/lualine.nvim"
    use "rcarriga/nvim-notify"

    -- explorer
    use "nvim-telescope/telescope.nvim"
    use {"nvim-telescope/telescope-fzf-native.nvim", run = "make"}
    use "jvgrootveld/telescope-zoxide"
    use "kevinhwang91/rnvimr"
    use "kyazdani42/nvim-tree.lua"
    use "justinmk/vim-dirvish"
    use "sindrets/diffview.nvim"

    -- LSP
    use "folke/trouble.nvim"
    use "tami5/lspsaga.nvim"
    use "hrsh7th/vim-vsnip"
    use "lewis6991/gitsigns.nvim"
    use "mhartington/formatter.nvim"
    use "neovim/nvim-lspconfig"
    use "rafamadriz/friendly-snippets"
    use "ray-x/lsp_signature.nvim"
    use "williamboman/nvim-lsp-installer"

    -- completion
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-nvim-lua"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-vsnip"
    use "hrsh7th/nvim-cmp"
    use "onsails/lspkind-nvim"

    -- editing
    use "windwp/nvim-ts-autotag"
    use "windwp/nvim-autopairs"
    use "mg979/vim-visual-multi"
    use "windwp/nvim-spectre"
    use "numToStr/Comment.nvim"
    use "folke/which-key.nvim"
    use "andymass/vim-matchup"

    -- web dev
    use "KabbAmine/vCoolor.vim"
    use "mattn/emmet-vim"
    use "NTBBloodbath/rest.nvim"
    use "norcalli/nvim-colorizer.lua"

    -- treesitter
    use "JoosepAlviste/nvim-ts-context-commentstring"
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}
    use "nvim-treesitter/nvim-treesitter-textobjects"
    use "nvim-treesitter/playground"

    -- classic
    use "junegunn/goyo.vim"
    use "milkypostman/vim-togglelist"
    use "moll/vim-bbye"
    -- use "rmagatti/auto-session"
    -- use "rmagatti/session-lens"
    use "skywind3000/asyncrun.vim"
    use {"michaelb/sniprun", run = "bash ./install.sh"}
    use "meain/vim-printer"
    use "tommcdo/vim-exchange"
    use "tpope/vim-abolish"
    use "tpope/vim-characterize"
    use "tpope/vim-eunuch"
    use "tpope/vim-fugitive"
    use "tpope/vim-repeat"
    use "tpope/vim-sleuth"
    use "tpope/vim-surround"
    use "tpope/vim-unimpaired"
    use "vim-scripts/BufOnly.vim"
    use "vim-scripts/loremipsum"
    use "voldikss/vim-translator"
    use "aklt/vim-substitute"
  end
)

-- Make sure packer is installed
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system(
    {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path
    }
  )
  vim.cmd("packadd packer.nvim")
end
