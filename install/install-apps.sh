#!/bin/bash

# ===== Prepare sources =====

# Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# Skype
sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"

# Infinality for better fonts
sudo add-apt-repository ppa:no1wantdthisname/ppa

# ===== Install apt packages =====

sudo apt-get update

PACKAGES=(
	compton
	curl
	dos2unix
	fontconfig-infinality
	freemind
	git
	gnuplot
	google-chrome-stable
	gpick
	i3
	i3blocks
	inkscape
	jabref
	keepass2
	krusader
	libappindicator1
	libgnome-keyring-dev
	libindicator7
	libxss1
	lyx
	lxappearance
	nautilus-dropbox
	neovim
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
	rofi
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
ln -s ~/opt/gsettings-info/gsettings-info ~/bin/gsettings-info


# ===== Proprietary drivers =====

# Consider configuring drivers in Software & updates -> Drivers

