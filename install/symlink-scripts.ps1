$SCRIPTS = "$HOME/dotfiles/scripts"
$BIN = "$HOME/bin"

# find all powershell scripts in scripts folder
# and symlink them according to their names
# NAME is filename without path and extension
Get-ChildItem -Path $SCRIPTS -Recurse -Depth 2 -Force `
  | Where-Object { $_.Extension -match "ps1" } `
  | ForEach-Object {
  $LINK_NAME = $_.Name
  $SCRIPT_PATH = $_.FullName
  New-Item -Type SymbolicLink -Force `
    -Path "$BIN\$LINK_NAME" `
    -Value "$SCRIPT_PATH"
  Write-Host "Symlink created: $BIN/$LINK_NAME -> $SCRIPT_PATH"
}
