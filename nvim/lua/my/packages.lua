-- https://github.com/wbthomason/packer.nvim

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data")
    .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  -- local
  use("~/dotfiles/nvim/plugin/nuxt-navigation/")
  use("~/dotfiles/nvim/plugin/cmp-nuxt-component/")
  use("~/dotfiles/nvim/plugin/cmp-css-variables/")
  use("~/dotfiles/nvim/plugin/cmp-scss-variables/")

  -- packer
  use("wbthomason/packer.nvim")

  -- library for multiple other plugins
  use("nvim-lua/plenary.nvim")

  -- theme and appearance
  use("EdenEast/nightfox.nvim")
  use("kyazdani42/nvim-web-devicons")
  use("hoob3rt/lualine.nvim")
  use("rcarriga/nvim-notify")
  use("nanozuki/tabby.nvim")

  -- explorer
  use("nvim-telescope/telescope.nvim")
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use("jvgrootveld/telescope-zoxide")
  use("cljoly/telescope-repo.nvim")
  use("nvim-telescope/telescope-file-browser.nvim")
  use("nvim-telescope/telescope-live-grep-args.nvim")
  use("jeetsukumaran/telescope-buffer-lines.nvim")
  use("smartpde/telescope-recent-files")
  use("kevinhwang91/rnvimr")
  use("kyazdani42/nvim-tree.lua")
  use("sindrets/diffview.nvim")
  use("ThePrimeagen/harpoon")
  use("stevearc/dressing.nvim")

  -- LSP
  use("folke/trouble.nvim")
  use("tami5/lspsaga.nvim")
  use("lewis6991/gitsigns.nvim")
  use("mhartington/formatter.nvim")
  use("neovim/nvim-lspconfig")
  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use("jose-elias-alvarez/null-ls.nvim")
  use("b0o/schemastore.nvim")
  use("Maan2003/lsp_lines.nvim")
  use("folke/zen-mode.nvim")
  use("j-hui/fidget.nvim")

  -- snippets
  use("L3MON4D3/LuaSnip")
  use("saadparwaiz1/cmp_luasnip")
  use("rafamadriz/friendly-snippets")

  -- completion
  use("hrsh7th/nvim-cmp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-nvim-lua")
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-nvim-lsp-signature-help")
  use("ray-x/lsp_signature.nvim")
  use("onsails/lspkind-nvim")
  -- use "rmagatti/goto-preview"
  use("petertriho/cmp-git")
  use("lttr/cmp-jira")
  use("folke/neodev.nvim")

  -- editing
  use("windwp/nvim-ts-autotag")
  use("windwp/nvim-autopairs")
  use("mg979/vim-visual-multi")
  use("nvim-pack/nvim-spectre")
  use("numToStr/Comment.nvim")
  use("folke/which-key.nvim")
  use("andymass/vim-matchup")

  -- web dev
  use("KabbAmine/vCoolor.vim")
  use("mattn/emmet-vim")
  use("rest-nvim/rest.nvim")
  use("brenoprata10/nvim-highlight-colors")

  -- testing
  use({
    "nvim-neotest/neotest",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "haydenmeade/neotest-jest",
    },
  })

  -- treesitter
  use("JoosepAlviste/nvim-ts-context-commentstring")
  use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
  use("nvim-treesitter/nvim-treesitter-textobjects")
  use("nvim-treesitter/playground")

  -- debbugging
  use("mfussenegger/nvim-dap")
  use("mxsdev/nvim-dap-vscode-js")
  use("rcarriga/nvim-dap-ui")
  use({
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npm run compile",
    tag = "v1.74.1", -- https://github.com/mxsdev/nvim-dap-vscode-js/issues/23
  })

  -- special languages
  use("hashivim/vim-terraform")
  use("jparise/vim-graphql")
  use("maxmellon/vim-jsx-pretty")
  use("jose-elias-alvarez/typescript.nvim")
  use("nikvdp/ejs-syntax")
  use("napmn/react-extract.nvim")
  use("Janiczek/vim-latte")
  use("Glench/Vim-Jinja2-Syntax")
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })

  -- help
  use("dbeniamine/cheat.sh-vim")
  use("ThePrimeagen/vim-be-good")
  use("aduros/ai.vim")
  use("PatrBal/vim-textidote")
  use("lalitmee/browse.nvim")

  -- executing and terminal
  use("kassio/neoterm")
  use("skywind3000/asyncrun.vim")
  use({ "michaelb/sniprun", run = "bash ./install.sh" })

  -- version control
  use("tpope/vim-fugitive")
  use("junegunn/gv.vim")
  use("cohama/agit.vim")
  use("rbong/vim-flog")

  -- classic
  use("airblade/vim-rooter")
  use("kevinhwang91/nvim-bqf")
  use("Olical/vim-enmasse")
  use("aklt/vim-substitute")
  use("milkypostman/vim-togglelist")
  use("moll/vim-bbye")
  use("tommcdo/vim-exchange")
  use("tpope/vim-abolish")
  use("tpope/vim-characterize")
  use("tpope/vim-eunuch")
  use("tpope/vim-repeat")
  use("tpope/vim-sleuth")
  use("tpope/vim-surround")
  use("tpope/vim-unimpaired")
  use("vim-scripts/BufOnly.vim")
  use("vim-scripts/loremipsum")
  use("voldikss/vim-translator")
  use({ "dhruvasagar/vim-prosession", requires = { "tpope/vim-obsession" } })
  use("stevearc/oil.nvim")

  if packer_bootstrap then
    require("packer").sync()
  end
end)
