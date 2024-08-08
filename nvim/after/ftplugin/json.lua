-- https://github.com/phelipetls/jsonpath.nvim

-- show json path in the winbar
if vim.fn.exists("+winbar") == 1 then
  vim.opt_local.winbar = "%{%v:lua.require'jsonpath'.get()%}"
end

-- send json path to clipboard
vim.keymap.set("n", "y<C-p>", function()
  vim.fn.setreg("+", require("jsonpath").get())
  print('JSON path copied to clipboard: "' .. require("jsonpath").get() .. '"')
end, { desc = "Copy json path", buffer = true })
