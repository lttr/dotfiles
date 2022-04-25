-- https://github.com/nvim-telescope/telescope.nvim

local telescopeActions = require "telescope.actions"
local telescopeLayoutActions = require "telescope.actions.layout"
require "telescope".setup {
  defaults = {
    initial_mode = "insert",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {mirror = false},
      vertical = {mirror = false}
    },
    file_ignore_patterns = {"^node_modules/", "%.lock"}, -- lua regexes
    mappings = {
      i = {
        ["<Esc>"] = telescopeActions.close,
        ["<C-p>"] = telescopeActions.close,
        ["<C-j>"] = telescopeActions.move_selection_next,
        ["<C-k>"] = telescopeActions.move_selection_previous,
        ["<C-s>"] = telescopeActions.select_horizontal,
        -- clear prompt
        ["<C-u>"] = false,
        ["<M-p>"] = telescopeLayoutActions.toggle_preview
      }
    }
  }
}

require "telescope".load_extension("fzf")
require "telescope".load_extension("zoxide")
require "telescope".load_extension("repo")
require "telescope".load_extension("file_browser")
require "telescope".load_extension("harpoon")
require "telescope".load_extension("live_grep_raw")

-- Zoxide extension
require("telescope._extensions.zoxide.config").setup(
  {
    -- show me only the path with '~' for the home directory
    list_command = "zoxide query -ls | awk '{ print $2 }' | sed 's:/home/lukas:~:'"
  }
)
