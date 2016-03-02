#!/bin/bash

# ===== Prepare sources =====

# Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# Skype
sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"


# ===== Install apt packages =====

sudo apt-get update

PACKAGES=(
	curl
	dos2unix
	freemind
	git
	gnuplot
	google-chrome-stable
	gpick
	inkscape
	jabref
	keepass2
	krusader
	libappindicator1
	libgnome-keyring-dev
	libindicator7
	libxss1
	lyx
	nautilus-dropbox
	# neovim
	nodejs
	npm
	openvpn
	python
	python3-dev
	python3-pip
	python-dbus
	python-dev
	python-gtk2
	python-pip
	python-setuptools
	python-wnck
	python-xlib
	qstardict
	silversearcher-ag
	skype
	stardict-czech
	stardict-english-czech
	tmux
	trash-cli
	umlet
	virtualbox
	vagrant
	viking
	vim-gtk
	vlc
	wmctrl
	xbindkeys
	xdotool
	zsh
)

for package in ${PACKAGES[@]}; do
  # sudo apt-get install -y $package 
  echo $package 
done


# ===== Custom applications =====

# gsettings-info
git clone https://github.com/jmatsuzawa/gsettings-info ~/opt/gsettings-info
ln -s gsettings-info/gsettings-info ~/bin/gsettings-info


# ===== Proprietary drivers =====

# Consider configuring drivers in Software & updates -> Drivers

