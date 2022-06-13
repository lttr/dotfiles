-- https://github.com/wbthomason/packer.nvim

require "packer".startup(
  function(use)
    -- local
    use "~/code/arrays.nvim"

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
    use "cljoly/telescope-repo.nvim"
    use "nvim-telescope/telescope-file-browser.nvim"
    use "nvim-telescope/telescope-live-grep-raw.nvim"
    use "kevinhwang91/rnvimr"
    use "kyazdani42/nvim-tree.lua"
    use "justinmk/vim-dirvish"
    use "sindrets/diffview.nvim"
    use "ThePrimeagen/harpoon"

    -- LSP
    use "folke/trouble.nvim"
    use "tami5/lspsaga.nvim"
    use "lewis6991/gitsigns.nvim"
    use "mhartington/formatter.nvim"
    use "neovim/nvim-lspconfig"
    use "williamboman/nvim-lsp-installer"

    -- snippets
    use "L3MON4D3/LuaSnip"
    use "saadparwaiz1/cmp_luasnip"
    use "rafamadriz/friendly-snippets"

    -- completion
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-nvim-lua"
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp-signature-help"
    use "onsails/lspkind-nvim"
    use "rmagatti/goto-preview"

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

    -- debbugging
    use "mfussenegger/nvim-dap"

    -- special languages
    use "hashivim/vim-terraform"
    use "jparise/vim-graphql"
    use "maxmellon/vim-jsx-pretty"
    use "preservim/vim-markdown"
    use "jose-elias-alvarez/nvim-lsp-ts-utils"
    use "nikvdp/ejs-syntax"

    -- classic
    use "Olical/vim-enmasse"
    use "aklt/vim-substitute"
    use "junegunn/goyo.vim"
    use "junegunn/gv.vim"
    use "milkypostman/vim-togglelist"
    use "moll/vim-bbye"
    use "skywind3000/asyncrun.vim"
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
    use {"dhruvasagar/vim-prosession", requires = {"tpope/vim-obsession"}}
    use {"michaelb/sniprun", run = "bash ./install.sh"}
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
