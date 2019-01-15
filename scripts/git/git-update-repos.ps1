Get-ChildItem -Recurse -Depth 2 -Force `
  | Where-Object { $_.Mode -match "h" -and $_.FullName -like "*\.git" } `
  | ForEach-Object {
  Set-Location $_.FullName
  Set-Location ../
  git pull
  Set-Location ../
}