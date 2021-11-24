vim.cmd([[
  command -nargs=+ C :normal !git commit -m "<args>"
]])

-- Close all other buffers
vim.cmd([[
  command Bonly :update | %bdelete | edit # | normal `”
]])
