#!/bin/bash

# The full path of the parent dir is the dotfiles dir
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

DOTFILES=(
    #aliases
    #dircolors
    gitconfig
    #gitignore_global
    ideavimrc
    vimrc
    vrapperrc
    xbindkeysrc
    zshrc
)

# Backup current dotfiles
mkdir -p ~/dotfiles_backup

for dotfile in ${DOTFILES[@]}; do
	if [[ -e ~/.$dotfile ]]; then
		cp -R ~/.$dotfile ~/dotfiles_backup
		echo "$dotfile backuped."
		rm -rf ~/.$dotfile
	fi
done

# Symlink new dotfiles
for dotfile in ${DOTFILES[@]}; do
	ln -s ${DOTFILES_ROOT}/$dotfile ~/.$dotfile
	echo "Symlink to ${DOTFILES_ROOT}/$dotfile created."
done
