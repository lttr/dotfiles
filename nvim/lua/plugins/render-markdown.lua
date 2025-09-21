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
    html = {
      comment = {
        conceal = false,
      },
    },
    code = {
      sign = false,
      left_pad = 0,
      right_pad = 3,
      inline_pad = 1,
      conceal_delimiters = false,
      border = "none",
      style = "normal", -- No language indicator
    },
  },
}
