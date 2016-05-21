#!/usr/bin/env bash

# Remove unnecessary directories from home
rmdir ~/Desktop 
rmdir ~/Documents 
rmdir ~/Downloads 
rmdir ~/Music 
rmdir ~/Pictures 
rmdir ~/Public 
rmdir ~/Templates 
rmdir ~/Videos

# Make useful directories inside home
mkdir -p ~/bin 
mkdir -p ~/down 
mkdir -p ~/opt 
mkdir -p ~/sandbox 
mkdir -p ~/tasks

# Prepare dirs for vim
mkdir -p ~/.vim 
mkdir -p ~/.vim/backups 
mkdir -p ~/.vim/undos
