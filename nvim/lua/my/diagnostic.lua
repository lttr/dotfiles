-- start with diagnostic text hidden
vim.diagnostic.config({
  float = { border = "rounded", source = "always" },
  signs = false,
  underline = true,
  update_in_insert = false,
  virtual_text = { current_line = true },
  -- virtual_lines = { current_line = true },
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
    vim.diagnostic.enable(false)
  end
end
