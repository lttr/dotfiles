-- https://github.com/mhartington/formatter.nvim

local prettier = function()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
    stdin = true
  }
end

local eslint = function()
  return {
    exe = "eslint_d",
    args = {"--stdin", "--stdin-filename", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), "--fix-to-stdout"},
    stdin = true
  }
end

-- local stylelint = function()
--   return {
--     exe = "stylelint",
--     args = {"--fix", "--stdin", "--stdin-filename", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
--     stdin = true
--   }
-- end

local luafmt = function()
  return {
    exe = "luafmt",
    args = {"--indent-count", 2, "--stdin"},
    stdin = true
  }
end

local xmllint = function()
  return {
    exe = "xmllint",
    args = {"--format", "--recover", "-"},
    stdin = true
  }
end

require("formatter").setup(
  {
    filetype = {
      javascript = {prettier, eslint},
      javascriptreact = {prettier, eslint},
      typescript = {prettier, eslint},
      typescriptreact = {prettier, eslint},
      html = {prettier},
      css = {prettier},
      scss = {prettier},
      json = {prettier},
      vue = {prettier, eslint},
      lua = {luafmt},
      xml = {xmllint}
    }
  }
)

vim.api.nvim_exec(
  [[
  augroup fmt
    autocmd!
    autocmd BufWritePost *.mjs,*.css,*.less,*.scss,*.json,*.yaml,*.html,*.tsx,*.jsx,*.ts,*.js,*.vue,*.svelte,*.lua FormatWrite
  augroup END
]],
  true
)
