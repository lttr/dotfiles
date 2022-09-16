-- https://github.com/tami5/lspsaga.nvim

require "lspsaga".init_lsp_saga {
  border_style = "round",
  rename_action_keys = {
    quit = "<Esc>"
  },
  code_action_icon = ""
}
