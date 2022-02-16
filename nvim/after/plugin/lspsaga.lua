-- https://github.com/tami5/lspsaga.nvim

local saga = require "lspsaga"
saga.init_lsp_saga {
  border_style = "round",
  rename_action_keys = {
    quit = "<Esc>"
  }
}
