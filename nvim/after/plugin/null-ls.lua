-- https://github.com/jose-elias-alvarez/null-ls.nvim

local null_ls = require "null-ls"

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup {
  sources = {
    --
    -- Code actions
    --
    -- These are provided by language servers
    --
    -- Formatting
    --
    null_ls.builtins.formatting.prettierd.with(
      {
        condition = function(utils)
          return not utils.root_has_file({"deno.json"})
        end
      }
    ),
    null_ls.builtins.formatting.deno_fmt.with(
      {
        condition = function(utils)
          return utils.root_has_file({"deno.json"})
        end
      }
    ),
    null_ls.builtins.formatting.eslint_d,
    -- null_ls.builtins.formatting.stylelint,
    null_ls.builtins.formatting.lua_format
    --
    -- Linting / diagnostics
    --
    -- These are run as language servers
  },
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
      vim.api.nvim_create_autocmd(
        "BufWritePre",
        {
          group = augroup,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({bufnr = bufnr})
          end
        }
      )
    end
  end
}
