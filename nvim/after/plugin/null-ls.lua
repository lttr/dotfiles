-- https://github.com/jose-elias-alvarez/null-ls.nvim

local utils = require("my.utils")
local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

local function has_stylelint()
  return utils.has_root_file({
    "stylelint.config.js",
    ".stylelintrc",
    ".stylelintrc.js",
    ".stylelintrc.cjs",
    ".stylelintrc.json",
  })
end

local function should_run_prettier()
  return not is_a_deno_project()
    and not utils.has_root_file({ ".stop-prettier" })
end

null_ls.setup({
  sources = {
    --
    -- Code actions
    --
    -- These are provided by language servers
    --
    -- Formatting
    --
    null_ls.builtins.formatting.prettierd.with({
      runtime_condition = should_run_prettier,
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "css",
        "scss",
        "less",
        "html",
        "json",
        "jsonc",
        "yaml",
        "markdown",
        "markdown.mdx",
        "graphql",
        "handlebars",
        "svelte",
      },
    }),
    null_ls.builtins.formatting.deno_fmt.with({ condition = is_a_deno_project }),
    null_ls.builtins.formatting.stylelint.with({
      runtime_condition = has_stylelint,
      filetypes = { "scss", "less", "css", "sass", "vue", "svelte" },
    }),
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.stylelint.with({
      runtime_condition = has_stylelint,
      filetypes = { "scss", "less", "css", "sass", "vue", "svelte" },
    }),
  },
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
        end,
      })
    end
    vim.diagnostic.config({
      virtual_text = false,
    })
  end,
})
