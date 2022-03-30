-- https://github.com/EdenEast/nightfox.nvim
-- https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/pallet/nordfox.lua

local pallets = {
  nordfox = {
    bg1 = "#2f2f2f", -- darker than the original "#2e3440"
    fg1 = "#c5c8c6" -- darker than the original "#cdcecf"
  }
}

local groups = {
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

local nightfox = require "nightfox"
nightfox.setup(
  {
    pallets = pallets,
    groups = groups,
    options = {
      styles = {
        -- Style that is applied to functions: see `highlight-args` for options
        comments = "NONE",
        functions = "NONE",
        keywords = "NONE",
        strings = "NONE",
        variables = "NONE"
      }
    }
  }
)

vim.cmd("colorscheme nordfox")
