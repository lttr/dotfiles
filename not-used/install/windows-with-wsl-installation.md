# Windows with WSL installation

## Enable WSL

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

Install `Ubuntu18` from Microsoft Store.

Start bash.exe. It will install the distro.

### Setup WSL config

In bash.exe:

```bash
sudo cp /mnt/c/Users/lukas/dotfiles/windows/wsl.conf /etc/wsl.conf
```

## Microsoft Store apps

Remove unwanted apps from Microsoft Store

```powershell
Get-AppxPackage -Name *partofname* | Remove-AppxPackage
```

List installed apps from Microsoft Store

```powershell
Get-AppxPackage | Where-Object { $_.Name -notlike 'microsoft*' -and $_.Name -notlike 'windows*' } | select -Property Name
```