-- https://github.com/Maan2003/lsp_lines.nvim
require "lsp_lines".setup {}

-- start with diagnostic text hidden
vim.diagnostic.config({virtual_lines = false})

-- Toogle diagnostics
DiagnosticsActive = true
ToggleDiagnostics = function()
  DiagnosticsActive = not DiagnosticsActive
  if DiagnosticsActive then
    vim.api.nvim_echo({{"Show diagnostics"}}, false, {})
    vim.diagnostic.enable()
  else
    vim.api.nvim_echo({{"Disable diagnostics"}}, false, {})
    vim.diagnostic.disable()
  end
end
