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

-- Notable mentions:
-- Harpoon by ThePrimeagen - alternate file navigation is enough for me
-- mhartington/formatter.nvim - I use conform.nvim instead, but might be useful
-- for on demand formatting with FormatWrite command
-- jose-elias-alvarez/null-ls.nvim

require("packer").startup(function(use)
  -- local
  use("~/dotfiles/nvim/plugin/eslint-spawn/")
  use("~/dotfiles/nvim/plugin/nuxt-navigation/")
  use("~/dotfiles/nvim/plugin/cmp-nuxt-component/")
  use("~/dotfiles/nvim/plugin/cmp-css-classes/")
  -- use("~/dotfiles/nvim/plugin/cmp-css-variables/")
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
  use("hiphish/rainbow-delimiters.nvim")

  -- explorer
  use({ "nvim-telescope/telescope.nvim", tag = "0.1.8" }) -- conservative updating, too much changes
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use("jvgrootveld/telescope-zoxide")
  use("cljoly/telescope-repo.nvim")
  use("nvim-telescope/telescope-file-browser.nvim")
  use("nvim-telescope/telescope-live-grep-args.nvim")
  use("jeetsukumaran/telescope-buffer-lines.nvim")
  use("smartpde/telescope-recent-files")
  use("isak102/telescope-git-file-history.nvim")
  use("kevinhwang91/rnvimr")
  use("kyazdani42/nvim-tree.lua")
  use("sindrets/diffview.nvim")
  use("stevearc/dressing.nvim")
  use({
    "antosha417/nvim-lsp-file-operations",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
  })

  -- LSP
  use("folke/trouble.nvim")
  use("lewis6991/gitsigns.nvim")
  use("neovim/nvim-lspconfig")
  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use("b0o/schemastore.nvim")
  use("folke/zen-mode.nvim")
  use("j-hui/fidget.nvim")
  use({ "nvimdev/lspsaga.nvim", after = "nvim-lspconfig" })
  use("stevearc/conform.nvim")
  use({ "dnlhc/glance.nvim", cmd = "Glance" })

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
  use("petertriho/cmp-git")
  use("lttr/cmp-jira")

  -- lua
  use("folke/neodev.nvim")

  -- editing
  use("windwp/nvim-ts-autotag")
  use("windwp/nvim-autopairs")
  use("mg979/vim-visual-multi")
  use("nvim-pack/nvim-spectre")
  use("numToStr/Comment.nvim")
  use("folke/which-key.nvim")
  use("andymass/vim-matchup")
  use("bennypowers/splitjoin.nvim")

  -- web dev
  use("mattn/emmet-vim")
  use("rest-nvim/rest.nvim")
  use("brenoprata10/nvim-highlight-colors")
  -- use("ESSO0428/nvim-html-css")
  use("lttr/cmp-css-variables")
  use("lttr/classy.nvim")

  -- testing
  use({
    "nvim-neotest/neotest",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "haydenmeade/neotest-jest",
      "nvim-neotest/nvim-nio",
    },
  })

  -- treesitter
  use("JoosepAlviste/nvim-ts-context-commentstring")
  use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
  use("nvim-treesitter/nvim-treesitter-textobjects")
  use("ckolkey/ts-node-action")
  use("ziontee113/syntax-tree-surfer")

  -- debbugging
  use("mfussenegger/nvim-dap")
  use("rcarriga/nvim-dap-ui")

  -- special languages
  use("hashivim/vim-terraform")
  use("jparise/vim-graphql")
  use("maxmellon/vim-jsx-pretty")
  use("davidosomething/format-ts-errors.nvim")
  use("pmizio/typescript-tools.nvim")
  use("nikvdp/ejs-syntax")
  use("napmn/react-extract.nvim")
  use("Janiczek/vim-latte")
  use("Glench/Vim-Jinja2-Syntax")
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })
  use("epwalsh/obsidian.nvim")
  use("towolf/vim-helm")
  use("joukevandermaas/vim-ember-hbs")
  use("Myzel394/jsonfly.nvim")
  use("phelipetls/jsonpath.nvim")
  use("luckasRanarison/tailwind-tools.nvim")

  -- help
  use("dbeniamine/cheat.sh-vim")
  use("ThePrimeagen/vim-be-good")
  use("PatrBal/vim-textidote")
  use("lalitmee/browse.nvim")
  use({
    "jackMort/ChatGPT.nvim",
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  })

  -- AI
  use("supermaven-inc/supermaven-nvim")
  use({
    "yetone/avante.nvim",
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "HakonHarnes/img-clip.nvim",
    },
    run = "make",
  })

  -- executing and terminal
  use("akinsho/toggleterm.nvim")
  use("skywind3000/asyncrun.vim")
  use({ "michaelb/sniprun", run = "bash ./install.sh" })
  use({
    "mikesmithgh/kitty-scrollback.nvim",
    disable = false,
    opt = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    config = function() require("kitty-scrollback").setup() end,
  })
  use("metakirby5/codi.vim")

  -- version control
  use("tpope/vim-fugitive")
  use("junegunn/gv.vim")
  use("cohama/agit.vim")
  use("rbong/vim-flog")

  -- classic
  use({
    "inkarkat/vim-ExtractMatches",
    requires = { "inkarkat/vim-ingo-library" },
  })
  use("airblade/vim-rooter")
  use("kevinhwang91/nvim-bqf")
  use("Olical/vim-enmasse")
  use("aklt/vim-substitute")
  use("milkypostman/vim-togglelist")
  use("moll/vim-bbye")
  use("tommcdo/vim-exchange")
  use("johmsalas/text-case.nvim")
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
