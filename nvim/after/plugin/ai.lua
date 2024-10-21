-- https://github.com/supermaven-inc/supermaven-nvim
require("supermaven-nvim").setup({
  color = {
    suggestion_color = "#5a524c",
    cterm = 245,
  },
  keymaps = {
    accept_suggestion = "<A-j>",
    clear_suggestion = "<A-]>",
    accept_word = "<A-m>",
  },
  log_level = "error",
})

require("lsp_signature").setup({
  bind = true,
  handler_opts = {
    border = "rounded",
  },
})
