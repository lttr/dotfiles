-- https://github.com/stevearc/conform.nvim

local prettier = { "prettierd", "prettier", stop_after_first = true }
local prettierAndEslint = { "eslint_d", "prettierd" }
local prettierAndEslintAndStylelint = { "eslint_d", "stylelint", "prettierd" }
local prettierAndEslint = { "stylelint", "prettierd" }

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = prettierAndEslint,
    javascriptreact = prettierAndEslint,
    typescript = prettierAndEslint,
    typescriptreact = prettierAndEslint,
    vue = prettierAndEslintAndStylelint,
    svelte = prettierAndEslint,
    html = prettier,
    css = prettierAndStylelint,
    scss = prettierAndStylelint,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    handlebars = prettier,
    graphql = prettier,
    markdown = prettier,
  },
  format_on_save = {
    timeout_ms = 2000,
    -- LSP formatting is used when no other formatters are available
    lsp_format = "fallback",
  },
})
