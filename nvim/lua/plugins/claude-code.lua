-- https://github.com/greggh/claude-code.nvim

return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  opts = {
    window = {
      position = "rightbelow vsplit",
      split_ratio = 0.38,
    },
    keymaps = {
      window_navigation = false,
      scrolling = false,
    },
  },
}
