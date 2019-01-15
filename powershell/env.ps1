# Clean TERM variable for fzf
# https://github.com/junegunn/fzf/wiki/Windows
if (Test-Path "Env:\TERM") {
  Remove-Item "Env:\TERM"
}