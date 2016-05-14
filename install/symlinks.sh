#!/usr/bin/env bash

set -e

# ===== Dotfiles =====

# The full path of the parent dir is the dotfiles dir
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)
DOTFILES=(
    aliases
    gitconfig
    ideavimrc
    kdiff3rc
    vimrc
    vrapperrc
	vim/colors
	vim/syntax
	i3
	config/dunst/dunstrc
	zshrc
	zshenv
	zprofile
)

# Backup current dotfiles
DOTFILES_BACKUP=~/dotfiles_backup
mkdir -p $DOTFILES_BACKUP

for dotfile in ${DOTFILES[@]}; do
	if [[ -e ~/.$dotfile ]]; then
		cp -rb ~/.$dotfile $DOTFILES_BACKUP
		echo "Dotfile backuped: ~/.$dotfile"
	fi
	ln -sf ${DOTFILES_ROOT}/$dotfile ~/.$dotfile
	echo "Symlink created: ~/.$dotfile"
done


# ===== Bin =====
if [[ -d ~/bin ]]; then
	cp -rb ~/bin $DOTFILES_BACKUP
	echo "~/bin backuped"
fi
rm -r ~/bin
ln -s ${DOTFILES_ROOT}/bin ~/bin
echo "Symlink created: ~/bin"


# ===== Syncfiles =====

SYNCDIR=~/Dropbox

# Krusader
KRUSADER_FILES=(
	~/.kde/share/config/krusaderrc
	~/.kde/share/apps/krusader/krbookmarks.xml
	~/.kde/share/apps/krusader/krusaderui.rc
	~/.kde/share/apps/krusader/useractions.xml
)
for krusader_file in "${KRUSADER_FILES[@]}"; do
	if [[ -e "$krusader_file" ]]; then
		cp -b "$krusader_file" $DOTFILES_BACKUP
		rm $krusader_file
	fi
done
KRUSADER_CONF=${SYNCDIR}/conf/krusader
ln -sf $KRUSADER_CONF/krusaderrc ~/.kde/share/config/krusaderrc 
ln -sf $KRUSADER_CONF/krbookmarks.xml ~/.kde/share/apps/krusader/krbookmarks.xml 
ln -sf $KRUSADER_CONF/krusaderui.rc ~/.kde/share/apps/krusader/krusaderui.rc 
ln -sf $KRUSADER_CONF/useractions.xml ~/.kde/share/apps/krusader/useractions.xml 
echo "Krusader configuration symlinked"

# Fonts
ln -sfn ${SYNCDIR}/conf/fonts ~/.fonts
echo "Fonts symlinked"
