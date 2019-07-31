#
# Command line
#


# Command prompt and other pshazz
try {
  Get-Command pshazz -ErrorAction Stop | Out-Null
  pshazz init 'default' | Out-Null
} catch {
}

# No sounds
Set-PSReadlineOption -BellStyle None

# Readline editing mode
Set-PSReadlineOption -EditMode Emacs

# Shortcuts
Set-PSReadLineKeyHandler -Key Alt+d -ScriptBlock { Invoke-FuzzyZLocation }
Set-PSReadLineKeyHandler -Key Alt+p -ScriptBlock { Invoke-FuzzyEdit }
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock { Invoke-FuzzyHistory }
Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock { Invoke-FuzzySetLocation }


# Colors
$host.PrivateData.ErrorForegroundColor = "Magenta"
$host.PrivateData.ErrorBackgroundColor = "Black"
$host.PrivateData.WarningForegroundColor = "DarkYellow"
$host.PrivateData.WarningBackgroundColor = "Black"
$host.PrivateData.DebugForegroundColor = "DarkGreen"
$host.PrivateData.DebugBackgroundColor = "Black"
$host.PrivateData.VerboseForegroundColor = "Yellow"
$host.PrivateData.VerboseBackgroundColor = "Black"
$host.PrivateData.ProgressForegroundColor = "White"
$host.PrivateData.ProgressBackgroundColor = "DarkGray"


# Include aliases
. $PSScriptRoot\aliases.ps1

# Include functions
Get-ChildItem "$PSScriptRoot\functions\*.ps1" | ForEach-Object { . $_ }

# Z
Import-Module ZLocation

# Fzf
Import-Module PSFzf -ArgumentList 'Ctrl+T', 'Ctrl+R'


# History
$HistoryFilePath = Join-Path ([Environment]::GetFolderPath('UserProfile')) .ps_history
Register-EngineEvent PowerShell.Exiting -Action { Get-History | Export-Clixml $HistoryFilePath } | Out-Null
if (Test-path $HistoryFilePath) {
  Import-Clixml $HistoryFilePath | Add-History
}
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Imports
. $PSScriptRoot\env.ps1