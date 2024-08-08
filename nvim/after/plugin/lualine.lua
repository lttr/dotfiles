-- https://github.com/nvim-lualine/lualine.nvim

local custom_gruvbox = require("lualine.themes.gruvbox")
local darkgray = "#3c3836"
local gray = "#a89984"
custom_gruvbox.insert.c.bg = darkgray
custom_gruvbox.insert.c.fg = gray

-- local function diff_source()
--   local gitsigns = vim.b.gitsigns_status_dict
--   if gitsigns then
--     if gitsigns.added > 0 or gitsigns.removed > 0 or gitsigns.changed > 0 then
--       return "~"
--     end
--   end
--   return ""
-- end

local sections = {
  lualine_a = {},
  -- {"FugitiveHead", icon = false},
  -- diff_source
  lualine_b = {},
  lualine_c = {
    {
      "filename",
      file_status = true,
      path = 1,
      shorting_target = 35,
    },
  },
  lualine_x = {
    { "filetype", colored = false, icon_only = true },
  },
  lualine_y = { "progress" },
  lualine_z = { "location" },
}

require("lualine").setup({
  options = {
    theme = custom_gruvbox,
  },
  sections = sections,
  inactive_sections = sections,
  extensions = { "quickfix", "fugitive" },
})
