#!/bin/bash
echo
echo '### sudo apt-get update'
echo
sudo apt-get update

echo
echo '### sudo apt-get upgrade --yes'
echo
sudo apt-get upgrade --yes

echo
echo '### sudo apt-get dist-upgrade --yes'
echo
sudo apt-get dist-upgrade --yes

echo
echo '### deno upgrade'
echo
deno upgrade

echo
echo '### pnpm update --global'
echo
pnpm update --global

echo
echo '### fnm install --lts'
echo
fnm install --lts

echo
echo '### brew update'
echo
brew update

echo
echo '### brew upgrade'
echo
brew upgrade

