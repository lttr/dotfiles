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

# find $SCRIPTS -type f -name "*sh" -executable \
# | while read EXE; do \
#     NAME=${EXE##*/};
#     NAME=${NAME%.*};
#     LINK=$BIN/$NAME
#     if [ -f $LINK ]; then
#         if [ "$(readlink $LINK)" = "$EXE" ]; then
#             echo "$LINK already exists"
#         else
#             echo "$LINK already exists but is a regular file!"
#         fi
#     else
#         echo "Creating link $LINK -> $EXE"
#         ln -s $EXE $BIN/$NAME;
#     fi
# done

# exit 0
