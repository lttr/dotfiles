-- https://github.com/brenoprata10/nvim-highlight-colors
-- alternative: https://github.com/NvChad/nvim-colorizer.lua

require("nvim-highlight-colors").setup({
  render = "virtual",
  enable_tailwind = true,
})

-- Turn off highlight colors by default, toggle on demand
require("nvim-highlight-colors").turnOff()
