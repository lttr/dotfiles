local cmd = vim.cmd
local fn = vim.fn

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

    -- explorer
    use "nvim-telescope/telescope.nvim"
    use {"nvim-telescope/telescope-fzf-native.nvim", run = "make"}
    use "kevinhwang91/rnvimr"
    use "sindrets/diffview.nvim"

    -- LSP
    use "folke/lua-dev.nvim"
    use "folke/trouble.nvim"
    use "glepnir/lspsaga.nvim"
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

    -- web dev
    use "KabbAmine/vCoolor.vim"

    -- treesitter
    use "JoosepAlviste/nvim-ts-context-commentstring"
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate"}

    -- classic
    use "junegunn/goyo.vim"
    use "mhinz/vim-startify"
    use "milkypostman/vim-togglelist"
    use "moll/vim-bbye"
    use "skywind3000/asyncrun.vim"
    use "tpope/vim-abolish"
    use "tpope/vim-characterize"
    use "tpope/vim-commentary"
    use "tpope/vim-eunuch"
    use "tpope/vim-fugitive"
    use "tpope/vim-repeat"
    use "tpope/vim-sleuth"
    use "tpope/vim-surround"
    use "tpope/vim-unimpaired"
    use "vim-scripts/BufOnly.vim"
    use "vim-scripts/loremipsum"
  end
)

-- Make sure packer is installed
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system(
    {
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path
    }
  )
  cmd("packadd packer.nvim")
end
