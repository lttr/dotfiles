-- https://github.com/wbthomason/packer.nvim

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require "packer".startup(
  function(use)
    -- local

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
    use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
    use "jvgrootveld/telescope-zoxide"
    use "cljoly/telescope-repo.nvim"
    use "nvim-telescope/telescope-file-browser.nvim"
    use "nvim-telescope/telescope-live-grep-args.nvim"
    use "jeetsukumaran/telescope-buffer-lines.nvim"
    use "smartpde/telescope-recent-files"
    use "kevinhwang91/rnvimr"
    use "kyazdani42/nvim-tree.lua"
    use "sindrets/diffview.nvim"
    use "ThePrimeagen/harpoon"
    use "stevearc/dressing.nvim"

    -- LSP
    use "folke/trouble.nvim"
    use "tami5/lspsaga.nvim"
    use "lewis6991/gitsigns.nvim"
    use "mhartington/formatter.nvim"
    use "neovim/nvim-lspconfig"
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "jose-elias-alvarez/null-ls.nvim"
    use "b0o/schemastore.nvim"
    use "Maan2003/lsp_lines.nvim"
    use "folke/zen-mode.nvim"

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
    use "ray-x/lsp_signature.nvim"
    use "onsails/lspkind-nvim"
    use "rmagatti/goto-preview"
    use "petertriho/cmp-git"
    use "lttr/cmp-jira"

    -- editing
    use "windwp/nvim-ts-autotag"
    use "windwp/nvim-autopairs"
    use "mg979/vim-visual-multi"
    use "nvim-pack/nvim-spectre"
    use "numToStr/Comment.nvim"
    use "folke/which-key.nvim"
    use "andymass/vim-matchup"

    -- web dev
    use "KabbAmine/vCoolor.vim"
    use "mattn/emmet-vim"
    use "rest-nvim/rest.nvim"
    use "norcalli/nvim-colorizer.lua"

    -- heavy development
    use {
      "nvim-neotest/neotest",
      requires = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "antoinemadec/FixCursorHold.nvim", -- probably can be removed in 0.8
        "haydenmeade/neotest-jest"
      }
    }

    -- treesitter
    use "JoosepAlviste/nvim-ts-context-commentstring"
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
    use "nvim-treesitter/nvim-treesitter-textobjects"
    use "nvim-treesitter/playground"

    -- debbugging
    use "mfussenegger/nvim-dap"

    -- special languages
    use "hashivim/vim-terraform"
    use "jparise/vim-graphql"
    use "maxmellon/vim-jsx-pretty"
    use "jose-elias-alvarez/typescript.nvim"
    use "nikvdp/ejs-syntax"
    use "napmn/react-extract.nvim"
    use "Janiczek/vim-latte"

    -- help
    use "dbeniamine/cheat.sh-vim"
    use "ThePrimeagen/vim-be-good"

    -- classic
    use "airblade/vim-rooter"
    use "kevinhwang91/nvim-bqf"
    use "Olical/vim-enmasse"
    use "aklt/vim-substitute"
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
    use { "dhruvasagar/vim-prosession", requires = { "tpope/vim-obsession" } }
    use { "michaelb/sniprun", run = "bash ./install.sh" }

    if packer_bootstrap then
      require("packer").sync()
    end
  end
)
