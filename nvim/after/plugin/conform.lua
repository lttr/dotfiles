-- https://github.com/stevearc/conform.nvim

local prettier = { "prettierd", "prettier", stop_after_first = true }

local utils = require("my.utils")

-- Files that signal a project use prettier. If any present in tree,
-- prefer prettier over oxfmt for JS/TS family.
local prettier_config_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.yaml",
  ".prettierrc.yml",
  ".prettierrc.toml",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
}

local function is_a_prettier_project()
  return utils.has_root_file(prettier_config_files)
end

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

-- JS/TS family: deno_fmt > prettier (if config) > vp fmt (default, run oxfmt).
-- eslint_d always runs first for lint-fixing.
local function pick_js_formatter(bufnr)
  local conform = require("conform")
  if is_a_deno_project() then
    if conform.get_formatter_info("deno_fmt", bufnr).available then
      return { "deno_fmt" }
    end
  end
  if is_a_prettier_project() then
    return { "eslint_d", "prettierd" }
  end
  print("conform: using vp fmt (oxfmt)")
  return { "eslint_d", "vp_fmt" }
end

require("conform").setup({
  formatters = {
    vp_fmt = {
      meta = {
        url = "https://viteplus.dev/guide/fmt",
        description = "vite-plus unified formatter (run oxfmt).",
      },
      command = "vp",
      args = { "fmt", "--stdin-filepath", "$FILENAME" },
      stdin = true,
      cwd = require("conform.util").root_file({ "package.json" }),
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = function(bufnr) return pick_js_formatter(bufnr) end,
    javascriptreact = function(bufnr) return pick_js_formatter(bufnr) end,
    typescript = function(bufnr) return pick_js_formatter(bufnr) end,
    typescriptreact = function(bufnr) return pick_js_formatter(bufnr) end,
    vue = function(bufnr) return pick_js_formatter(bufnr) end,
    svelte = function(bufnr) return pick_js_formatter(bufnr) end,
    html = prettier,
    css = prettier,
    -- scss = prettier,
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
