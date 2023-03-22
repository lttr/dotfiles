-- https://github.com/mg979/vim-visual-multi

vim.cmd([[
  let g:VM_theme = "nord"
  let g:VM_maps["Undo"] = "u"
  let g:VM_maps["Select Operator"] = "v"
  " For some reason this does not remap <C-n>
  let g:VM_maps["Find Under"] = "<C-m>"
]])
