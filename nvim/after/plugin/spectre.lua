-- https://github.com/nvim-pack/nvim-spectre

require "spectre".setup {
  mapping = {
    ["send_to_qf"] = {
      map = "<C-q>",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all item to quickfix"
    }
  }
}
