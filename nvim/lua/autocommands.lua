-- Start terminal in insert mode
vim.cmd([[
    augroup term
      autocmd!
      autocmd TermOpen * startinsert
    augroup END
  ]], true)

-- Restore last cursor position and center the screen,
-- do it only if the cursor is not on first line
vim.cmd(
  [[
    augroup last_position
      autocmd!
      autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"zvzz' | endif
    augroup END
  ]],
  true
)

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]
