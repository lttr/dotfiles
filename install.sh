#!/usr/bin/env bash

# Upgrade system
sudo apt update && sudo apt full-upgrade -y
# Install deno
curl -fsSL https://deno.land/x/install/install.sh | sh
# Install symlinks in order to configure zsh
cd $HOME/dotfiles/bootstrap/
$HOME/.deno/bin/deno task run --filter symlink
# Install zsh
sudo apt install zsh -y
# Use configured zsh to install everyting else
zsh -c "deno task run"
