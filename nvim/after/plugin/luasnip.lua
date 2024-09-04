-- https://github.com/L3MON4D3/LuaSnip
-- https://github.com/saadparwaiz1/cmp_luasnip
-- https://github.com/rafamadriz/friendly-snippets

require("luasnip.loaders.from_vscode").lazy_load({
  paths = { "~/dotfiles/nvim/snippets/" },
})
require("luasnip").filetype_extend("javascript", { "javascriptreact" })
require("luasnip").filetype_extend("typescript", { "typescriptreact" })
