-- https://github.com/stevearc/oil.nvim

-- disable Netrw build in plugin, use Oil instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("oil").setup({
  keymaps = {
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-s>"] = "actions.select_split",
    ["<M-p>"] = "actions.preview",
  },
  view_options = {
    show_hidden = true,
  },
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
})
