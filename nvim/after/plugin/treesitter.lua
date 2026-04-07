-- https://github.com/nvim-treesitter/nvim-treesitter (0.12+)

-- ts-context-commentstring (independent of nvim-treesitter module API)
require("ts_context_commentstring").setup({})
vim.g.skip_ts_context_commentstring_module = true

-- Install parsers
require("nvim-treesitter").install({ "all" })

-- Highlight is auto-enabled in 0.12 for languages with bundled queries

-- Treesitter indent (replaces old indent = { enable = true })
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Textobjects
-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

-- Select
local sel = require("nvim-treesitter-textobjects.select").select_textobject
for _, map in ipairs({
  { "af", "@function.outer" }, { "if", "@function.inner" },
  { "ar", "@parameter.outer" }, { "ir", "@parameter.inner" },
  { "ac", "@class.outer" }, { "ic", "@class.inner" },
  { "aa", "@attribute.outer" }, { "ia", "@attribute.inner" },
  { "ai", "@conditional.outer" }, { "ii", "@conditional.inner" },
}) do
  vim.keymap.set({ "x", "o" }, map[1], function() sel(map[2], "textobjects") end)
end

-- Move
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "<A-]>", function() move.goto_next_start("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "<A-[>", function() move.goto_previous_start("@function.outer", "textobjects") end)

-- Swap
local swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<localleader>r", function() swap.swap_next("@parameter.inner") end)
vim.keymap.set("n", "<localleader>R", function() swap.swap_previous("@parameter.inner") end)
