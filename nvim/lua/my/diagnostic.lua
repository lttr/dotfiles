-- start with diagnostic text hidden
vim.diagnostic.config({
  float = { border = "rounded", source = "always" },
  signs = false,
  underline = true,
  update_in_insert = false,
  virtual_text = false,
  virtual_lines = false, -- toggle with coe
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

ToggleDiagnosticsVirtualLines = function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end
