-- https://github.com/hiphish/rainbow-delimiters.nvim
require("rainbow-delimiters.setup").setup({
  blacklist = { "html", "vue" },
  highlight = {
    "RainbowDelimiterBlue",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
  },
})
