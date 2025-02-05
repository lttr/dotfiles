-- https://github.com/nanozuki/tabby.nvim

local theme = {
  fill = "TabLineFill",
  current_tab = "TabLineSel",
  tab = "TabLine",
}

require("tabby.tabline").set(function(line)
  return {
    line.tabs().foreach(function(tab)
      -- remove count of wins in tab with [n+] included in tab.name()
      local name = tab.name()
      local index = string.find(name, "%[%d")
      local tab_name = index and string.sub(name, 1, index - 1) or name

      local hl = tab.is_current() and theme.current_tab or theme.tab
      return {
        line.sep(" ", hl, theme.fill),
        tab_name,
        line.sep("", hl, theme.fill),
        hl = hl,
        margin = " ",
      }
    end),
    hl = theme.fill,
  }
end)
