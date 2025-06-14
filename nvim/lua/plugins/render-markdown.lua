-- https://github.com/MeanderingProgrammer/render-markdown.nvim

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "codecompanion" },
  opts = {
    preset = "obsidian",
    heading = {

    code = {
      sign = false,
      left_pad = 3,
      right_pad = 3,
    },
  },
}
