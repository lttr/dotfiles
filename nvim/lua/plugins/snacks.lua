-- https://github.com/folke/snacks.nvim

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    input = {
      enabled = true,
      win = {
        width = 80,
      },
    },
    image = { enabled = true },
    picker = { enabled = true },
  },
  keys = {
    {
      "<leader><space>",
      function() Snacks.picker.smart() end,
      desc = "Smart Find Files",
    },
  },
}
