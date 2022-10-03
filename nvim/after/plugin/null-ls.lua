-- https://github.com/jose-elias-alvarez/null-ls.nvim

local null_ls = require "null-ls"

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup {
  sources = {
    --
    -- Code actions
    --
    null_ls.builtins.code_actions.gitsigns,
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
    -- null_ls.builtins.formatting.eslint_d,
    -- null_ls.builtins.formatting.stylelint,
    null_ls.builtins.formatting.lua_format,
    --
    -- Linting
    --
    -- NOTE deno-lint is run through denols, therefore not here
    null_ls.builtins.diagnostics.eslint_d.with(
      {
        condition = function(utils)
          return utils.root_has_file({".eslintrc.*"})
        end
        -- extra_args = {
        --   "--config",
        --   vim.fn.expand("~/.config/eslint/config.json")
        -- },
        -- timeout = 20000
      }
    )
    -- null_ls.builtins.diagnostics.stylelint
  },
  -- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({group = augroup, buffer = bufnr})
      vim.api.nvim_create_autocmd(
        "BufWritePre",
        {
          group = augroup,
          pattern = {
            "*.mjs",
            "*.css",
            "*.less",
            "*.scss",
            "*.json",
            "*.yaml",
            "*.html",
            "*.tsx",
            "*.jsx",
            "*.ts",
            "*.js",
            "*.vue",
            "*.svelte"
          },
          callback = function()
            vim.lsp.buf.format(
              {
                bufnr = bufnr,
                filter = function(clientNullLs)
                  return clientNullLs.name == "null-ls"
                end
              }
            )
          end
        }
      )
    end
  end
}
