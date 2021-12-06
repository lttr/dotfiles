local fn = vim.fn
local g = vim.g

require "packages"
require "settings"
require "commands"
require "functions"
require "lsp-settings"
require "completion"
require "comments"
require "keybindings"
require "formatting"

----- plugins

--
-- telescope.nvim
--
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

--
-- lssaga.nvim
--
local saga = require "lspsaga"
saga.init_lsp_saga {
  border_style = "round",
  rename_action_keys = {
    quit = "<Esc>"
  }
}

--
-- nvim-treesitter
--
require("nvim-treesitter.configs").setup {
  ensure_installed = "maintained",
  context_commentstring = {enable = true},
  highlight = {enable = false},
  autotag = {enable = true},
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner"
      }
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]]"] = "@function.outer"
      },
      goto_previous_start = {
        ["[["] = "@function.outer"
      }
    },
    swap = {
      enable = true,
      swap_next = {
        ["<localleader>p"] = "@parameter.inner"
      },
      swap_previous = {
        ["<localleader>P"] = "@parameter.inner"
      }
    }
  }
}

require "nvim-treesitter.configs".setup {}

--
-- vim-togglelist
--
-- https://github.com/milkypostman/vim-togglelist
g.toggle_list_no_mappings = 1

--
-- nvim-autopairs
--
local autopairs = require("nvim-autopairs")
autopairs.setup()

_G.MUtils = {}
MUtils.completion_confirm = function()
  if fn.pumvisible() ~= 0 then
    return autopairs.esc("<cr>")
  else
    return autopairs.autopairs_cr()
  end
end

--
-- gitsigns.nvim
--
require("gitsigns").setup()

--
-- vim-visual-multi
--
g.VM_theme = "nord"

--
-- lualine.vim
--

local custom_gruvbox = require "lualine.themes.gruvbox"
local darkgray = "#3c3836"
local gray = "#a89984"
custom_gruvbox.insert.c.bg = darkgray
custom_gruvbox.insert.c.fg = gray

require("lualine").setup {
  options = {
    theme = custom_gruvbox
  },
  sections = {
    lualine_a = {},
    lualine_c = {
      {
        "filename",
        file_status = true,
        path = 1
      }
    },
    lualine_x = {"filetype", "fileformat", "encoding"}
  },
  extensions = {"quickfix", "fugitive"}
}

--
-- goyo
--
vim.g.goyo_width = 100 -- (default: 80)
vim.g.goyo_margin_top = 2 --  (default: 4)
vim.g.goyo_margin_bottom = 2 --  (default: 4)

--
-- nvim-spectre
--
require("spectre").setup(
  {
    mapping = {
      ["send_to_qf"] = {
        map = "<C-q>",
        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
        desc = "send all item to quickfix"
      }
    }
  }
)
