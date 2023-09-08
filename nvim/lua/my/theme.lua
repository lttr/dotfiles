-- https://github.com/EdenEast/nightfox.nvim

-- Gruvbox colors
-- https://github.com/eddyekofo94/gruvbox-flat.nvim/blob/master/lua/gruvbox/colors.lua

-- bg = "#32302f",
-- bg2 = "#282828",
-- bg_visual = "#45403d",
-- border = "#5a524c",
-- line_cursor = "#45403d",
-- prompt_border = "#ddc7a1",
-- bg_highlight = "#5a524c",
-- fg = "#d4be98",
-- fg_light = "#ddc7a1",
-- fg_dark = "#d4be98",
-- tree_normal = "#aa9987",
-- comment = "#7c6f64",
-- fg_gutter = "#5a524c",
-- dark5 = "#5a524c",
-- blue = "#7daea3",
-- aqua = "#89b482",
-- purple = "#d3869b",
-- orange = "#e78a4e",
-- yellow = "#d8a657",
-- yellow2 = "#b47109",
-- bg_yellow = "#a96b2c",
-- green = "#a9b665",
-- red = "#ea6962",
-- red1 = "#c14a4a",
-- black = "#1d2021",
-- git = { delete = "#c14a4a", add = "#6f8352", change = "#b47109", bg_red = "#ae5858" },
-- gitSigns = { delete = "#ae5858", add = "#6f8352", change = "#a96b2c" },

-- Nordfox colors
-- https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/palette/nordfox.lua

-- black   = Shade.new("#3b4252", "#465780", "#353a45"),
-- red     = Shade.new("#bf616a", "#d06f79", "#a54e56"),
-- green   = Shade.new("#a3be8c", "#b1d196", "#8aa872"),
-- yellow  = Shade.new("#ebcb8b", "#f0d399", "#d9b263"),
-- blue    = Shade.new("#81a1c1", "#8cafd2", "#668aab"),
-- magenta = Shade.new("#b48ead", "#c895bf", "#9d7495"),
-- cyan    = Shade.new("#88c0d0", "#93ccdc", "#69a7ba"),
-- white   = Shade.new("#e5e9f0", "#e7ecf4", "#bbc3d4"),
-- orange  = Shade.new("#c9826b", "#d89079", "#b46950"),
-- pink    = Shade.new("#bf8red8bc", "#d092ce", "#a96ca5"),
-- comment = "#60728a",
-- bg0     = "#232831", -- Dark bg (status line and float)
-- bg1     = "#2e3440", -- Default bg
-- bg2     = "#39404f", -- Lighter bg (colorcolm folds)
-- bg3     = "#444c5e", -- Lighter bg (cursor line)
-- bg4     = "#5a657d", -- Conceal, border fg
-- fg0     = "#c7cdd9", -- Lighter fg
-- fg1     = "#cdcecf", -- Default fg
-- fg2     = "#abb1bb", -- Darker fg (status line)
-- fg3     = "#7e8188", -- Darker fg (line numbers, fold colums)
-- sel0    = "#3e4a5b", -- Popup bg, visual selection bg
-- sel1    = "#4f6074", -- Popup sel bg, search bg}

--
-- My colors
--
local bg = "#2d2d2d" -- from Tomorrow Night Eighties
local fg = "#bdc0be" -- slightly darker then fg1
local fg3 = "#5a524c"

local bg_visual = "#45403d"
local border = "#5a524c"

local green = "#8aa872"
local yellow = "#d8a657"
local red = "#a54e56"
local black = "#353a45"
local blue = "#668aab"
local magenta = "#9d7495"
local cyan = "#69a7ba"
local white = "#bbc3d4"
local orange = "#b46950"
local pink = "#a96ca5"

-- Nightfox
local nightfox = require "nightfox"
local Color = require "nightfox.lib.color"

-- Derived colors

local bg_color = Color.from_hex(bg)

local green_color = Color.from_hex(green)
local yellow_color = Color.from_hex(yellow)
local red_color = Color.from_hex(red)

local green_transparent = green_color:blend(bg_color, 0.4)
local yellow_transparent = yellow_color:blend(bg_color, 0.4)
local red_transparent = red_color:blend(bg_color, 0.4)

-- Nightfox config

local palettes = {
  nordfox = {
    bg1 = bg,
    fg1 = fg,
    fg3 = fg3,
    black = black,
    red = red,
    green = green,
    yellow = yellow,
    blue = blue,
    magenta = magenta, -- this is base color not dimmed
    cyan = cyan,
    white = white,
    orange = orange,
    pink = pink,
    sel0 = Color.from_hex(bg_visual):lighten(-4):to_css(),
    sel1 = Color.from_hex(border):lighten(-4):to_css()
  }
}

-- Group of current token set by Treesitter can be find by
-- :TSHighlightCapturesUnderCursor from treesitter-playground
local groups = {
  GitSignsAdd = { fg = green_transparent:to_css() },
  GitSignsChange = { fg = yellow_transparent:to_css() },
  GitSignsRemove = { fg = red_transparent:to_css() },
  TSType = { fg = yellow, link = "" },
  TSParameter = { fg = fg, link = "" },
  Folded = { fg = "palette.fg2", link = "" },
  Visual = { bg = bg_visual, link = "" },
  Search = { bg = Color.from_hex(blue):lighten(-25):to_css(), link = "" },
  LspSignatureActiveParameter = { fg = "palette.orange" },
  Hint = { bg = "palette.bg1", fg = "palette.comment" },
  NormalFloat = { bg = "palette.bg1" },
  ["@tag"] = { fg = "palette.magenta" },
  ["@tag.attribute"] = { fg = "palette.fg1" },
  ["@parameter"] = { fg = "palette.fg1" },
  TabLine = { fg = "#666666", bg = "#181818" },
  TabLineSel = { fg = "#999999", bg = "#444444" },
  TabLineFill = { fg = "palette.fg2", bg = "#262626" }
}

-- Treesitter groups mapping
-- https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/group/modules/treesitter.lua
-- https://github.com/EdenEast/nightfox.nvim/blob/main/lua/nightfox/palette/nordfox.lua
local specs = {
  nordfox = {
    syntax = {
      -- default text color is enough for properties
      field = "fg1",
      builtin1 = "yellow",
      bracket = "pink", -- Brackets and Punctuation
      builtin0 = "fg1", -- Builtin variable
      builtin2 = "orange", -- Builtin const
      builtin3 = "red", -- Not used
      comment = "comment", -- Comment
      conditional = "magenta", -- Conditional and loop
      const = "orange", -- Constants, imports and booleans
      dep = "fg3", -- Deprecated
      func = "blue", -- Functions and Titles
      ident = "cyan", -- Identifiers
      keyword = "magenta", -- Keywords
      number = "orange", -- Numbers
      operator = "fg2", -- Operators
      preproc = "pink", -- PreProc
      regex = "yellow", -- Regex
      statement = "magenta", -- Statements
      string = "green", -- Strings
      type = "yellow", -- Types
      variable = "white" -- Variables
    }
  }
}

nightfox.setup(
  {
    palettes = palettes,
    groups = {
      nordfox = groups
    },
    specs = specs,
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
