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
vim.cmd [[
  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Force removal of anoying format option (see :help fo-table)
vim.cmd [[
  augroup force_format_options
      autocmd!
      autocmd BufEnter * setlocal formatoptions-=o
  augroup end
]]

-- Filetypes
vim.cmd [[
  augroup filetypes
      autocmd!
      autocmd BufNewFile,BufRead *.ejs.t :set filetype=ejs
  augroup end
]]

-- from https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/utils.lua
local root_has_file_matches = function(pattern)
  local handle = vim.loop.fs_scandir(vim.loop.cwd())
  local entry = vim.loop.fs_scandir_next(handle)
  while entry do
    if entry:match(pattern) then
      return true
    end
    entry = vim.loop.fs_scandir_next(handle)
  end
  return false
end

-- Deno make group
local denoMakeGroup = vim.api.nvim_create_augroup("DenoMake", { clear = true })
vim.api.nvim_create_autocmd(
  "BufRead",
  {
    callback = function()
      if (root_has_file_matches("deno.json") or root_has_file_matches("deno.jsonc")) then
        vim.bo.makeprg = [[deno lint --quiet --compact]]
        vim.bo.errorformat = [[%f: line %l\, col %c - %m]]
      end
    end,
    group = denoMakeGroup
  }
)

-- Autosave
vim.cmd [[
  augroup autosave
    autocmd InsertLeave * if &readonly==0 && filereadable(bufname('%')) | silent update | endif
  augroup end
]]
