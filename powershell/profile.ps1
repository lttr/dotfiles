#
# Command line
#

# Command prompt and other pshazz
try {
  Get-Command pshazz -ErrorAction Stop | Out-Null
  pshazz init 'default' | Out-Null
}
catch {
}

# No sounds
Set-PSReadlineOption -BellStyle None

# Readline editing mode
Set-PSReadlineOption -EditMode Emacs

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
$host.PrivateData.ProgressBackgroundColor = "Gray"


# Include aliases
$OwnAliasesDir = "$env:USERPROFILE\Documents\PowerShell"
. $OwnAliasesDir\aliases.ps1

# Include functions

$OwnFunctionsDir = "$env:USERPROFILE\Documents\PowerShell\Functions"
Write-Verbose "Loading own PowerShell functions from:"
Write-Verbose "$OwnFunctionsDir"
Get-ChildItem "$OwnFunctionsDir\*.ps1" | ForEach-Object {.$_}
