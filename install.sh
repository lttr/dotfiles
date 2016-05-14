#!/usr/bin/env bash

set -e

help() {
	echo "First argument = What would you like to install?"
	echo "applications   -> Download and install applications"
	echo "directories    -> Create necessary directories in home folder"
	echo "gnome-settings -> Apply a couple of gnome settings"
	echo "gnome-theme    -> Download and install gnome theme"
	echo "symlinks       -> Install symlinks"
	echo "help           -> Show this help"
}

INSTALL_DIR=install

case "$1" in
	"help" )
		help
		;;
	"applications" )
		./$INSTALL_DIR/applications.sh
		;;
	"directories" )
		./$INSTALL_DIR/directories.sh
		;;
	"gnome-settings" )
		./$INSTALL_DIR/gnome-settings.sh
		;;
	"gnome-theme" )
		./$INSTALL_DIR/gnome-theme.sh
		;;
	"symlinks" )
		./$INSTALL_DIR/symlinks.sh
		;;
	"all" )
		./$INSTALL_DIR/applications.sh
		./$INSTALL_DIR/directories.sh
		./$INSTALL_DIR/gnome-settings.sh
		./$INSTALL_DIR/gnome-theme.sh
		./$INSTALL_DIR/symlinks.sh
		;;
	* )
		help
		;;
esac
