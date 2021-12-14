-- https://github.com/EdenEast/nightfox.nvim

local nightfox = require "nightfox"
nightfox.setup(
  {
    fox = "nordfox",
    colors = {bg = "#2d2d2d"},
    styles = {
      -- Style that is applied to functions: see `highlight-args` for options
      comments = "NONE",
      functions = "NONE",
      keywords = "NONE",
      strings = "NONE",
      variables = "NONE"
    },
    hlgroups = {
      htmlH1 = {style = "NONE"},
      htmlH2 = {style = "NONE"},
      htmlH3 = {style = "NONE"},
      htmlH4 = {style = "NONE"},
      htmlH5 = {style = "NONE"},
      MatchParenCur = {fg = "${orange}", style = "NONE"},
      MatchWord = {style = "NONE"},
      LspReferenceText = {bg = "#3c3836"},
      LspReferenceRead = {bg = "#3c3836"},
      LspReferenceWrite = {bg = "#3c3836"}
    }
  }
)
nightfox.load()
