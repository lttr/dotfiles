-- https://github.com/windwp/nvim-autopairs

local autopairs = require("nvim-autopairs")
autopairs.setup()
autopairs.remove_rule('"')
autopairs.remove_rule("'")
autopairs.remove_rule("`")

_G.MUtils = {}
MUtils.completion_confirm = function()
  if vim.fn.pumvisible() ~= 0 then
    return autopairs.esc("<cr>")
  else
    return autopairs.autopairs_cr()
  end
end
