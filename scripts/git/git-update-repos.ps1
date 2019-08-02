Get-ChildItem -Recurse -Depth 2 -Force `
| Where-Object { $PSItem.FullName -like "*\.git" } `
| ForEach-Object {
  Write-Output "$($PSItem.Parent.FullName)"
  Set-Location $PSItem.Parent
  git pull
  Set-Location ../
}