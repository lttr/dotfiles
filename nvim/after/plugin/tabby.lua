-- https://github.com/nanozuki/tabby.nvim

local theme = {
  fill = "TabLineFill",
  current_tab = "TabLineSel",
  tab = "TabLine",
}
require("tabby.tabline").set(function(line)
  return {
    line.tabs().foreach(function(tab)
      local hl = tab.is_current() and theme.current_tab or theme.tab
      return {
        line.sep(" ", hl, theme.fill),
        tab.number(),
        tab.name(),
        line.sep("", hl, theme.fill),
        hl = hl,
        margin = " ",
      }
    end),
    hl = theme.fill,
  }
end)
