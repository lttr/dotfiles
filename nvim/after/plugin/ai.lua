-- https://github.com/aduros/ai.vim
-- make sure to export OPENAI_API_KEY

vim.g.ai_no_mappings = true

vim.api.nvim_set_keymap("n", "<C-t>", ":AI ", { noremap = true })
vim.api.nvim_set_keymap("v", "<C-t>", ":AI ", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-t>", "<Esc>:AI<CR>a", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-g>t",
  ":AI fix grammar and spelling and replace slang and contractions with a formal academic writing style<CR>",
  { noremap = true })
