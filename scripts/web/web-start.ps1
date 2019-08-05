Param([string]$name)

if ( !$name ) {
  Write-Host "Missing sandbox name"
}
else {
  Set-Location ${env:USERPROFILE}\sandbox

  pollinate ${env:USERPROFILE}\code\web-start --name $name

  Set-Location $name

  git init
  git add .
  git commit -m "Initial commit"

  code .
  code --reuse-window index.html style.css script.js

  browser-sync start --server --files . --no-notify --open .
}