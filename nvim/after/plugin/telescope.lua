-- https://github.com/nvim-telescope/telescope.nvim

local telescopeActions = require "telescope.actions"
require "telescope".setup {
  defaults = {
    initial_mode = "insert",
    sorting_strategy = "descending",
    layout_strategy = "vertical",
    layout_config = {
      horizontal = {mirror = false},
      vertical = {mirror = false}
    },
    mappings = {
      i = {
        ["<Esc>"] = telescopeActions.close,
        ["<C-p>"] = telescopeActions.close,
        ["<C-j>"] = telescopeActions.move_selection_next,
        ["<C-k>"] = telescopeActions.move_selection_previous
      }
    }
  }
}

require "telescope".load_extension("fzf")
require "telescope".load_extension("zoxide")
require "telescope".load_extension("repo")
require "telescope".load_extension("file_browser")
