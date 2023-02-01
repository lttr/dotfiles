#!/bin/bash
set -e
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade

deno upgrade
pnpm update --global
fnm install --lts
brew update
brew upgrade
