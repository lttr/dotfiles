-- https://github.com/windwp/nvim-autopairs

local autopairs = require("nvim-autopairs")
autopairs.setup({
  map_cr = true,
})
autopairs.remove_rule('"')
autopairs.remove_rule("'")
autopairs.remove_rule("`")
