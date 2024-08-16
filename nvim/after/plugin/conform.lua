-- https://github.com/stevearc/conform.nvim

local prettier = { "prettierd", "prettier", stop_after_first = true }
local prettierAndEslint = { "eslint_d", "prettierd" }
local prettierAndEslintAndStylelint = { "eslint_d", "stylelint", "prettierd" }
local prettierAndStylelint = { "stylelint", "prettierd" }

-- local utils = require("my.utils")

-- local function is_a_deno_project()
--   return utils.has_root_file({ "deno.json", "deno.jsonc" })
-- end

---@param bufnr integer
---@param ... string
---@return string
local function firstAvailable(bufnr, ...)
  local conform = require("conform")
  for i = 1, select("#", ...) do
    local formatter = select(i, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = prettierAndEslint,
    javascriptreact = prettierAndEslint,
    typescript = function(bufnr)
      return { firstAvailable(bufnr, "deno_fmt", "prettierd"), "eslint_d" }
    end,
    typescriptreact = function(bufnr)
      return { firstAvailable(bufnr, "deno_fmt", "prettierd"), "eslint_d" }
    end,
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
