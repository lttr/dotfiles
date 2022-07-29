-- https://github.com/nvim-treesitter/nvim-treesitter

require "nvim-treesitter.configs".setup {
  ensure_installed = "all",
  context_commentstring = {enable = true},
  highlight = {
    enable = true,
    disable = {}
  },
  autotag = {enable = true},
  matchup = {
    enable = true, -- disabled, since the indication at the end of a function is distracting
    disable = {} -- optional, list of language that will be disabled
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ar"] = "@parameter.outer",
        ["ir"] = "@parameter.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner"
      }
    },
    move = {
      enable = true,
      set_jumps = true -- whether to set jumps in the jumplist
      -- goto_next_start = {
      --   ["<C-j>"] = "@function.outer"
      -- },
      -- goto_previous_start = {
      --   ["<C-k>"] = "@function.outer"
      -- }
    },
    swap = {
      enable = true,
      swap_next = {
        ["<localleader>r"] = "@parameter.inner"
      },
      swap_previous = {
        ["<localleader>R"] = "@parameter.inner"
      }
    }
  }
}

require "nvim-treesitter.highlight".set_custom_captures {}
