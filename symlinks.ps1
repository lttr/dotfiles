# Powershell profile

New-Item -ItemType Directory -Force -Path "$HOME\Documents\PowerShell"
New-Item -Type SymbolicLink -Force `
  -Path "$HOME\Documents\PowerShell\Functions" `
  -Value "$HOME\dotfiles\powershell\functions"
New-Item -Type SymbolicLink -Force `
  -Path "$HOME\Documents\PowerShell\aliases.ps1" `
  -Value "$HOME\dotfiles\powershell\aliases.ps1"
New-Item -Type SymbolicLink -Force `
  -Path "$HOME\Documents\PowerShell\env.ps1" `
  -Value "$HOME\dotfiles\powershell\env.ps1"
New-Item -Type SymbolicLink -Force `
  -Path "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" `
  -Value "$HOME\dotfiles\powershell\profile.ps1"


# Hyper terminal config
New-Item -Type SymbolicLink -Force `
  -Path "$HOME\.hyper.js" `
  -Value "$HOME\dotfiles\hyperterm\hyper.js"