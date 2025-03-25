vim.cmd([[
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
]])

P = function(...)
  print(type(...))
  if type(...) == "table" then
    print(vim.inspect(...))
  else
    print(vim.inspect({ ... }))
  end
  return ...
end

RELOAD = function(...) return require("plenary.reload").reload_module(...) end

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

-- Custom function to send the volar/client/findFileReference request
-- https://github.com/vuejs/language-tools/discussions/3244
FindVueFileReferences = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)
  vim.lsp.buf_request(
    bufnr,
    "volar/client/findFileReference",
    { textDocument = { uri = uri } },
    function(err, result, ctx, config)
      if err then
        vim.notify(
          "Error finding references: " .. vim.inspect(err),
          vim.log.levels.ERROR
        )
      else
        -- Convert the result to quickfix items
        local items = {}
        for _, ref in ipairs(result) do
          table.insert(items, {
            filename = vim.uri_to_fname(ref.uri),
            lnum = ref.range.start.line + 1,
            col = ref.range.start.character + 1,
            text = "Reference",
          })
        end
        -- Populate the quickfix
        vim.fn.setqflist(items)
        -- Open the quickfix window
        vim.cmd("copen")
      end
    end
  )
end
vim.keymap.set(
  "n",
  "<leader>fR",
  "<cmd>lua FindVueFileReferences()<CR>",
  { noremap = true, silent = true }
)
