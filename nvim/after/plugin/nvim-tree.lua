-- https://github.com/kyazdani42/nvim-tree.lua

require "nvim-tree".setup {
  sync_root_with_cwd = true,
  select_prompts = true,
  git = {
    ignore = false
  },
  notify = {
    threshold = vim.log.levels.WARN
  },
  view = {
    adaptive_size = true,
    float = {
      enable = true,
    }
  },
}
