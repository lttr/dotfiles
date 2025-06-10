local utils = require("my.utils")

-- Start terminal in insert mode
vim.api.nvim_create_autocmd("TermOpen", { command = "startinsert" })

-- Restore last cursor position and center the screen,
-- do it only if the cursor is not on first line
vim.cmd(
  [[
    augroup last_position
      autocmd!
      autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"zvzz' | endif
    augroup end
  ]],
  true
)

-- Highlight on yank
vim.cmd([[
  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

-- Force removal of anoying format option (see :help fo-table)
vim.cmd([[
  augroup force_format_options
      autocmd!
      autocmd BufEnter * setlocal formatoptions-=o
  augroup end
]])

-- Filetypes
vim.cmd([[
  augroup filetypes
      autocmd!
      autocmd BufNewFile,BufRead *.ejs.t :set filetype=ejs
  augroup end
]])

-- Autosave
vim.cmd([[
  augroup autosave
    autocmd InsertLeave * if &readonly==0 && filereadable(bufname('%')) | silent write | endif
  augroup end
]])

-- Save on Buf leave
vim.cmd([[
  augroup buf_leave_save
    autocmd!
    au BufLeave * silent! wall
  augroup end
]])

vim.api.nvim_create_autocmd("BufRead", {
  callback = function()
    if utils.has_root_file({ ".obsidian.vimrc" }) then
      vim.opt.conceallevel = 2
    end
  end,
  group = vim.api.nvim_create_augroup("Obsidian", { clear = true }),
})
