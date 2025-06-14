-- https://github.com/MeanderingProgrammer/render-markdown.nvim

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "codecompanion" },
  opts = {
    preset = "obsidian",
    heading = {
      icons = {}, -- display normal # signs instead of icons
      sign = false,
    },
    code = {
      sign = false,
      left_pad = 3,
      right_pad = 3,
      inline_pad = 1,
      border = "thick", -- Background covers leading and trailing ```
      style = "normal", -- No language indicator
    },
  },
}
