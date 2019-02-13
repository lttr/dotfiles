Get-ChildItem -Recurse -Depth 1 -Force `
  | Where-Object { $PSItem.Mode -match "h" -and $PSItem.FullName -like "*\.git" } `
  | ForEach-Object {
  Set-Location $PSItem.FullName
  Set-Location ../
  git pull
  Set-Location ../
}