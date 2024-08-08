-- https://github.com/nvim-treesitter/nvim-treesitter

require("ts_context_commentstring").setup({})
vim.g.skip_ts_context_commentstring_module = true

require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
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
        ["ic"] = "@class.inner",
        ["aa"] = "@attribute.outer",
        ["ia"] = "@attribute.inner",
        ["ai"] = "@conditional.outer",
        ["ii"] = "@conditional.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["<A-]>"] = "@function.outer",
      },
      goto_previous_start = {
        ["<A-[>"] = "@function.outer",
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ["<localleader>r"] = "@parameter.inner",
      },
      swap_previous = {
        ["<localleader>R"] = "@parameter.inner",
      },
    },
    lsp_interop = {
      enable = true,
      border = "rounded",
      peek_definition_code = {
        ["gF"] = "@function.outer",
        ["gC"] = "@class.outer",
      },
    },
  },
})
