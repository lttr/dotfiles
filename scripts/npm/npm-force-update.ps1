# update all dependencies to latest versions even major ones

param(
  [switch]$dry = $false
)

$outdatedPackages = npm outdated --json --long | ConvertFrom-Json
$outdatedPackages | ForEach-Object {
  $PSItem | Get-Member -MemberType NoteProperty | ForEach-Object {
    $packageName = $PSItem.name
    $packageProperties = $outdatedPackages."$($packageName)"
    $nameAndVersion = "${packageName}@$($packageProperties.latest)"
    if ($dry) {
      Write-Host $nameAndVersion
    } else {
      npm install $nameAndVersion
    }
  }
}