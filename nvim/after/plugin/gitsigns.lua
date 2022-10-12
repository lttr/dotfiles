-- https://github.com/lewis6991/gitsigns.nvim

require("gitsigns").setup {
  on_attach = require "keybindings".gitsigns_keybindings
}
