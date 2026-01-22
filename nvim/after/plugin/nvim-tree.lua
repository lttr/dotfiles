-- https://github.com/kyazdani42/nvim-tree.lua

require("nvim-tree").setup({
  update_focused_file = {
    enable = true,
  },
  sync_root_with_cwd = true,
  select_prompts = true,
  notify = {
    threshold = vim.log.levels.WARN,
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
  },
  renderer = {
    highlight_modified = "name",
  },
})

local api = require("nvim-tree.api")
api.events.subscribe(
  api.events.Event.FileCreated,
  function(file) vim.cmd("edit " .. file.fname) end
)
