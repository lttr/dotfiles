# Clean unwanted aliases
Remove-Item -Force alias:gl -ErrorAction SilentlyContinue

# Factory for creating simple aliases
function Set-DynamicAlias {
  param(
    [String]$Alias,
    [String]$Command
  )
  New-Item -Path function:\ -Name "global:$Alias" -Value "$Command" -Force | Out-Null
}
New-Alias -Name da -Value Set-DynamicAlias -Force -Option AllScope

# Powershell

da admin "Start-Process pwsh -Verb runAs"

# Directories

function Set-Directory {
  # Create new directory path and do not warn about already existing directories
  New-Item -Path "$($args[0])" -ItemType Directory -Force
  Set-Location "$($args[0])"
}
New-Alias -Name mkcd -Value Set-Directory -Force -Option AllScope

da u "cd .."
da uu "cd ../.."
da uuu "cd ../../.."

# Domat

da contport "cd $HOME/code/contport/web-portal/WebSiteSolution/Web"

# NPM

function nr { & npm run $args }

# git

function c { & git commit -m "$args" }

function ga { & git add $args }

da gaa "git add --all"
da gunstage "git reset --"

da gbr "git branch"
da gbra "git branch -a"
da gco "git checkout"

da gcan "git commit --amend --no-edit"
da gci "git commit"
da gcm "git commit -m"
da gca "git commit -a -m"

da galiases "git config --global --includes --get-regexp alias"
da gcg "git config --global --includes"

da gd "git diff"
da gds "git diff --staged"
da gdh "git diff HEAD"

da gchanged "git update-index --no-assume-unchanged"
da gunchanged "git update-index --assume-unchanged"
da gignored "git ls-files --other --ignored --exclude-standard"

$logformat = 'log --graph --abbrev-commit --decorate --format=format:"%C(yellow)%h%C(reset) %C(cyan)%ci%x08%x08%x08%x08%x08%x08%x08%x08%x08%C(reset) %s %C(green)(%an)%C(reset)%C(bold green)%d%C(reset)"'

da gl "git log --graph --decorate --oneline -n20"
da gla "git log --graph --decorate --oneline"
da gle "git log --graph --decorate --oneline --all -n20"
da glea "git log --graph --decorate --oneline --all"
da glmy 'git log --graph --decorate --oneline --all -n20 --author=\"Lukas Trumm\"'
da glf "git $logformat -n8 --name-status"
da gm "git $logformat -n20"
da gma "git $logformat"
da gme "git $logformat --all -n20"
da gmea "git $logformat --all"
da gfh "git $logformat --all --follow"

da gsf "git show --name-status"
da gfind "git log --all --name-status --grep"

da gfe "git fetch"

da gst "git status"
da gs "git status -s"
da grs "git recursive-status"

da gsl "git stash list"

# Azure

function pr { & vsts code pr create --title "$args" }

# Web

da bsync "browser-sync start --server --files . --no-notify --open ."

# Edit configuration

da ealias "code $HOME/dotfiles/powershell/aliases.ps1"
da eprofile "code $HOME/dotfiles/powershell/profile.ps1"
da eenv "code $HOME/dotfiles/powershell/env.ps1"