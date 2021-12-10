-- Commit from ex command
--

vim.cmd(
  [[
  function! GitAddAndCommit(args)
    echo system("! git add --all; git commit -m \"" . a:args . "\"")
  endfunction
  function! GitCommit(args)
    echo system("! git commit -m \"" . a:args . "\"")
  endfunction
  execute "command! -nargs=1 CA call GitAddAndCommit(<q-args>)"
  execute "command! -nargs=1 C call GitCommit(<q-args>)"
]]
)

-- Close all other buffers
vim.cmd([[
  command! Bonly :update | %bdelete | edit # | normal `”
]])
