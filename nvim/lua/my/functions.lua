vim.cmd(
  [[
function! SaveAndExec() abort
  if &filetype == 'vim'
    :silent! write
    :source %
  elseif &filetype == 'lua'
    :silent! write
    :luafile %
  endif

  return
endfunction
]]
)

P = function(...)
  print(type(...))
  if type(...) == "table" then
    print(vim.inspect(...))
  else
    print(vim.inspect({...}))
  end
  return ...
end

RELOAD = function(...)
  return require("plenary.reload").reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

GetVisualSelection = function()
  vim.cmd([[noau normal! "vy"]])
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", {})

  text = string.gsub(text, "\n", "")
  if #text > 0 then
    return text
  else
    return ""
  end
end
