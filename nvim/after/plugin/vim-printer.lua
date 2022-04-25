-- https://github.com/meain/vim-printer

-- The text inside {$} will be replaced by the variable
vim.cmd([[
  let g:vim_printer_items = { 'vue': 'console.log("{$}:", {$})' }
]])
