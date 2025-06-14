-- https://github.com/folke/snacks.nvim

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    input = { enabled = true },
    image = { enabled = true },
    picker = { enabled = true },
  },
}
