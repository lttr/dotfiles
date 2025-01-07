-- https://github.com/epwalsh/obsidian.nvim

require("obsidian").setup({
  dir = "~/ia",
  completion = {
    nvim_cmp = true,
  },
  disable_frontmatter = true,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/ia/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/ia/*.md",
  },
})
