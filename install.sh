#!/usr/bin/env bash

# Upgrade system
sudo apt update && sudo apt full-upgrade -y
# Install deno if not present
if ! command -v deno &> /dev/null; then
    curl -fsSL https://deno.land/x/install/install.sh | sh -s -- -y
fi
# Install symlinks in order to configure zsh
cd $HOME/dotfiles/bootstrap/
$HOME/.deno/bin/deno task run --filter symlink
# Install zsh
sudo apt install zsh -y
# Use configured zsh to install everyting else
zsh -c "deno task run"
# Use SSH for this repo from now
cd $HOME/dotfiles
git remote remove origin
git remote add origin git@github.com:lttr/dotfiles.git
git fetch origin
git branch --set-upstream-to=origin/master master
