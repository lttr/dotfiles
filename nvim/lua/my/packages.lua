-- https://github.com/folke/lazy.nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Notable mentions:
-- Harpoon by ThePrimeagen - alternate file navigation is enough for me
-- mhartington/formatter.nvim - I use conform.nvim instead, but might be useful
-- for on demand formatting with FormatWrite command

require("lazy").setup({
  { import = "plugins" },
  -- local
  { dir = "~/dotfiles/nvim/plugin/eslint-spawn/" },
  -- { dir = "~/dotfiles/nvim/plugin/nuxt-navigation/" },
  { dir = "~/dotfiles/nvim/plugin/cmp-nuxt-component/" },
  { dir = "~/dotfiles/nvim/plugin/cmp-css-classes/" },
  { dir = "~/dotfiles/nvim/plugin/cmp-css-variables/" },
  { dir = "~/dotfiles/nvim/plugin/cmp-scss-variables/" },

  -- library for multiple other plugins
  "nvim-lua/plenary.nvim",

  -- theme and appearance
  "EdenEast/nightfox.nvim",
  "kyazdani42/nvim-web-devicons",
  "hoob3rt/lualine.nvim",
  "rcarriga/nvim-notify",
  "nanozuki/tabby.nvim",
  "hiphish/rainbow-delimiters.nvim",

  -- explorer
  { "nvim-telescope/telescope.nvim", tag = "0.1.8" }, -- conservative updating, too much changes
  -- "nvim-telescope/telescope.nvim",
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  "jvgrootveld/telescope-zoxide",
  "cljoly/telescope-repo.nvim",
  "nvim-telescope/telescope-file-browser.nvim",
  "nvim-telescope/telescope-live-grep-args.nvim",
  "jeetsukumaran/telescope-buffer-lines.nvim",
  "smartpde/telescope-recent-files",
  "isak102/telescope-git-file-history.nvim",
  "kyazdani42/nvim-tree.lua",
  "sindrets/diffview.nvim",
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
  },

  -- LSP
  "folke/trouble.nvim",
  "lewis6991/gitsigns.nvim",
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "b0o/schemastore.nvim",
  "folke/zen-mode.nvim",
  "j-hui/fidget.nvim",
  { "nvimdev/lspsaga.nvim", dependencies = { "neovim/nvim-lspconfig" } },
  "stevearc/conform.nvim",
  { "dnlhc/glance.nvim", cmd = "Glance" },

  -- snippets
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "rafamadriz/friendly-snippets",

  -- completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-nvim-lua",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-nvim-lsp-signature-help",
  "ray-x/lsp_signature.nvim",
  "onsails/lspkind-nvim",
  "petertriho/cmp-git",
  "lttr/cmp-jira",

  -- lua
  "folke/neodev.nvim",

  -- editing
  "windwp/nvim-ts-autotag",
  "windwp/nvim-autopairs",
  "mg979/vim-visual-multi",
  "nvim-pack/nvim-spectre",
  "numToStr/Comment.nvim",
  "folke/which-key.nvim",
  "andymass/vim-matchup",
  "bennypowers/splitjoin.nvim",

  -- web dev
  "mattn/emmet-vim",
  -- {
  --   "rest-nvim/rest.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   config = function()
  --     require("rest-nvim").setup({
  --       skip_ssl_verification = false,
  --     })
  --   end,
  -- },
  "brenoprata10/nvim-highlight-colors",
  "lttr/classy.nvim",

  -- data
  "tpope/vim-dadbod",

  -- testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "haydenmeade/neotest-jest",
      "nvim-neotest/nvim-nio",
    },
  },

  -- treesitter
  "JoosepAlviste/nvim-ts-context-commentstring",
  {
    "nvim-treesitter/nvim-treesitter",
    build = false, -- Disable auto-build to avoid tarball issues
  },
  "nvim-treesitter/nvim-treesitter-textobjects",

  "ziontee113/syntax-tree-surfer",

  -- debbugging
  "mfussenegger/nvim-dap",
  "rcarriga/nvim-dap-ui",

  -- special languages
  "hashivim/vim-terraform",
  "jparise/vim-graphql",
  "maxmellon/vim-jsx-pretty",
  "davidosomething/format-ts-errors.nvim",
  -- "pmizio/typescript-tools.nvim",
  "nikvdp/ejs-syntax",
  "Janiczek/vim-latte",
  "Glench/Vim-Jinja2-Syntax",
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  "epwalsh/obsidian.nvim",
  "towolf/vim-helm",
  "joukevandermaas/vim-ember-hbs",
  "Myzel394/jsonfly.nvim",
  "phelipetls/jsonpath.nvim",
  "luckasRanarison/tailwind-tools.nvim",

  -- help
  "dbeniamine/cheat.sh-vim",
  "ThePrimeagen/vim-be-good",
  "lalitmee/browse.nvim",

  -- AI
  "supermaven-inc/supermaven-nvim",
  -- {
  --   "yetone/avante.nvim",
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --   build = "make",
  -- },

  -- executing and terminal
  "akinsho/toggleterm.nvim",
  "skywind3000/asyncrun.vim",
  { "michaelb/sniprun", build = "bash ./install.sh" },
  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
    config = function() require("kitty-scrollback").setup() end,
  },
  "metakirby5/codi.vim",

  -- version control
  "tpope/vim-fugitive",
  "junegunn/gv.vim",

  -- classic
  {
    "inkarkat/vim-ExtractMatches",
    dependencies = { "inkarkat/vim-ingo-library" },
  },
  "airblade/vim-rooter",
  "kevinhwang91/nvim-bqf",
  "Olical/vim-enmasse",
  "aklt/vim-substitute",
  "milkypostman/vim-togglelist",
  "moll/vim-bbye",
  "tommcdo/vim-exchange",
  "johmsalas/text-case.nvim",
  "tpope/vim-characterize",
  "tpope/vim-eunuch",
  "tpope/vim-repeat",
  "tpope/vim-sleuth",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "vim-scripts/BufOnly.vim",
  "vim-scripts/loremipsum",
  "voldikss/vim-translator",
  { "dhruvasagar/vim-prosession", dependencies = { "tpope/vim-obsession" } },
  "stevearc/oil.nvim",
})
