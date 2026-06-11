-- https://github.com/stevearc/conform.nvim

local utils = require("my.utils")

-- Config files that signal which formatter a project uses. Mirrors the Claude
-- Code format hook (claude/hooks/format-code.sh): only format when a recognised
-- config is found in the tree (current dir up to HOME); otherwise skip — no
-- implicit formatting. prettier wins ties over oxfmt.
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

local oxfmt_config_files = {
  "vite.config.ts",
  "vite.config.js",
  "vite.config.mjs",
  "vite.config.cjs",
  "vite.config.mts",
  "vite.config.cts",
  ".oxfmtrc",
  ".oxfmtrc.json",
  "oxfmt.config.js",
  "oxfmt.config.cjs",
  "oxfmt.config.mjs",
  "oxfmt.config.ts",
  "oxfmt.config.json",
}

local function is_a_prettier_project()
  return utils.has_root_file(prettier_config_files)
end

local function is_an_oxfmt_project()
  return utils.has_root_file(oxfmt_config_files)
end

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

-- Markup/data filetypes (json, css, html, yaml, md, ...): prettier or oxfmt by
-- config, else no formatting.
local function pick_markup_formatter()
  if is_a_prettier_project() then
    return { "prettierd", "prettier", stop_after_first = true }
  end
  if is_an_oxfmt_project() then
    return { "vp_fmt" }
  end
  return {}
end

-- JS/TS family: deno_fmt > prettier > oxfmt by config, else no formatting.
-- eslint_d runs first to apply lint fixes before the formatter.
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
  if is_an_oxfmt_project() then
    return { "eslint_d", "vp_fmt" }
  end
  return {}
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
    javascript = pick_js_formatter,
    javascriptreact = pick_js_formatter,
    typescript = pick_js_formatter,
    typescriptreact = pick_js_formatter,
    vue = pick_js_formatter,
    svelte = pick_js_formatter,
    html = pick_markup_formatter,
    css = pick_markup_formatter,
    -- scss = pick_markup_formatter,
    json = pick_markup_formatter,
    jsonc = pick_markup_formatter,
    yaml = pick_markup_formatter,
    handlebars = pick_markup_formatter,
    graphql = pick_markup_formatter,
    markdown = pick_markup_formatter,
  },
  format_on_save = {
    timeout_ms = 2000,
    -- LSP formatting is used when no other formatters are available
    lsp_format = "fallback",
  },
})
