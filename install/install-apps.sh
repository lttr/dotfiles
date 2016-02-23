#!/bin/bash

# Prepare sources

## Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

## Skype
sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"


# Install apt packages

sudo apt-get update

for package in $(sed '/^#/d' packages-list.txt); do
  sudo apt-get install -y $package 
done

# Custom applications

## gsettings-info
git clone https://github.com/jmatsuzawa/gsettings-info ~/opt/gsettings-info
ln -s gsettings-info/gsettings-info ~/bin/gsettings-info

