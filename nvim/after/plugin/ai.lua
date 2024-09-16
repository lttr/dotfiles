-- https://github.com/supermaven-inc/supermaven-nvim
require("supermaven-nvim").setup({
  -- keymaps are set in completion plugin configuration for Tab key
  disable_keymaps = true,
  color = {
    suggestion_color = "#5a524c",
    cterm = 245,
  },
})

-- https://github.com/Exafunction/codeium.nvim
-- require("codeium").setup({})

require("lsp_signature").setup({
  bind = true,
  handler_opts = {
    border = "rounded",
  },
})
