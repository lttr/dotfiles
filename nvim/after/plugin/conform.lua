-- https://github.com/stevearc/conform.nvim

local prettier = { "prettierd", "prettier", stop_after_first = true }
local prettierAndEslint = { "eslint_d", "prettierd" }
local prettierAndEslintAndStylelint = { "eslint_d", "stylelint", "prettierd" }
local prettierAndStylelint = { "stylelint", "prettierd" }

local utils = require("my.utils")

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

local function pick_deno_or_not(bufnr)
  local conform = require("conform")
  if is_a_deno_project() then
    if conform.get_formatter_info("deno_fmt", bufnr).available then
      return { "deno_fmt" }
    end
  else
    return { "eslint_d", "prettierd" }
  end
end

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = prettierAndEslint,
    javascriptreact = prettierAndEslint,
    typescript = function(bufnr) return pick_deno_or_not(bufnr) end,
    typescriptreact = function(bufnr) return pick_deno_or_not(bufnr) end,
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
