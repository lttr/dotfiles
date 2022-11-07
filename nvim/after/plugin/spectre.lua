-- https://github.com/nvim-pack/nvim-spectre

require "spectre".setup {
  mapping = {
    ["send_to_qf"] = {
      map = "<C-q>",
      cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
      desc = "send all item to quickfix"
    }
  },
  find_engine = {
    -- rg is map with finder_cmd
    ["rg"] = {
      cmd = "rg",
      args = {
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        -- added
        "--smart-case",
        "--hidden",
        "--no-ignore",
        "--glob",
        "!.git",
        "--glob",
        "!node_modules",
        "--glob",
        "!build/",
        "--glob",
        "!dist/",
        "--glob",
        "!.lock"
      },
      options = {
        ["ignore-case"] = {
          value = "--ignore-case",
          icon = "[I]",
          desc = "ignore case"
        },
        ["hidden"] = {
          value = "--hidden",
          desc = "hidden file",
          icon = "[H]"
        }
      }
    }
  }
}
