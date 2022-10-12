-- https://github.com/nvim-telescope/telescope.nvim

local actions = require "telescope.actions"
local layout_actions = require "telescope.actions.layout"
local action_state = require "telescope.actions.state"
local live_grep_args_actions = require "telescope-live-grep-args.actions"

function actions.my_select_action(prompt_bufnr)
  local entry = action_state.get_selected_entry(prompt_bufnr)
  vim.fn.setreg('"', entry.value)
  actions.close(prompt_bufnr)
end

require "telescope".setup {
  defaults = {
    initial_mode = "insert",
    sorting_strategy = "descending",
    layout_strategy = "flex",
    layout_config = {
      flex = {
        flip_columns = 140
      }
    },
    file_ignore_patterns = {"^node_modules/", "%.lock"}, -- lua regexes
    path_display = function(_, path)
      return path:gsub(vim.env.HOME .. "/", "")
    end,
    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-p>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-u>"] = false, -- clear prompt
        ["<M-p>"] = layout_actions.toggle_preview,
        ["<C-y>"] = actions.my_select_action -- copy a value
      }
    }
  },
  extensions = {
    live_grep_args = {
      auto_quoting = true,
      mappings = {
        i = {
          ["<C-e>"] = live_grep_args_actions.quote_prompt(),
          ["<C-k>"] = actions.move_selection_previous
        }
      }
    },
    recent_files = {
      ignore_patterns = {"/%.local/", "/tmp/"}
    }
  }
}

require "telescope".load_extension("buffer_lines")
require "telescope".load_extension("file_browser")
require "telescope".load_extension("fzf")
require "telescope".load_extension("harpoon")
require "telescope".load_extension("live_grep_args")
require "telescope".load_extension("recent_files")
require "telescope".load_extension("repo")
require "telescope".load_extension("zoxide")

-- Zoxide extension
require("telescope._extensions.zoxide.config").setup(
  {
    -- show me only the path with '~' for the home directory
    list_command = "zoxide query -ls | grep -v '\\.local' | awk '{ print $2 }' | sed 's:" .. vim.env.HOME .. "/::'",
    mappings = {
      ["<C-l>"] = {
        action = function(selection)
          vim.cmd("lcd " .. selection.path)
        end
      }
    }
  }
)
