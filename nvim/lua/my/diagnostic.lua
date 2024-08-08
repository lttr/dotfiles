-- https://github.com/Maan2003/lsp_lines.nvim
require("lsp_lines").setup({
  source = "always",
})

-- start with diagnostic text hidden
vim.diagnostic.config({
  float = { border = "rounded", source = "always" },
  signs = false,
  underline = true,
  update_in_insert = false,
  -- virtual_text is set for every lsp provider among handlers
  -- see lsp-settings.lua
  virtual_lines = false, -- show virtual lines only on demand
})

-- Toogle diagnostics
DiagnosticsActive = true
ToggleDiagnostics = function()
  DiagnosticsActive = not DiagnosticsActive
  if DiagnosticsActive then
    vim.api.nvim_echo({ { "Show diagnostics" } }, false, {})
    vim.diagnostic.enable()
  else
    vim.api.nvim_echo({ { "Disable diagnostics" } }, false, {})
    vim.diagnostic.disable()
  end
end
