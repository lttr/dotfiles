-- https://github.com/stevearc/oil.nvim

-- disable Netrw build in plugin, use Oil instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require "oil".setup({
  keymaps = {
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-s>"] = "actions.select_split",
  }
})
