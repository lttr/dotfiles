vim.diagnostic.config(
  {
    virtual_text = false,
    signs = false,
    underline = true,
    update_in_insert = false,
    severity_sort = true
  }
)

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    signs = {
      severity_limit = "Hint"
    },
    virtual_text = {
      severity_limit = "Warning"
    }
  }
)
