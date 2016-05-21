#!/bin/bash

# ===== Prepare sources =====

# Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

# Skype
sudo add-apt-repository "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"

# Infinality for better fonts
sudo add-apt-repository ppa:no1wantdthisname/ppa

# Vivaldi?

# ===== Install apt packages =====

sudo apt-get update

PACKAGES=(
    artha
    compton
    curl
    dict
    dict-gcide
    dict-freedict-eng-ces
    dict-freedict-ces-eng
    dos2unix
    fontconfig-infinality
    freemind
    git
    gimp
    gnuplot
    google-chrome-stable
    gpick
    gthumb
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
    scrot
    silversearcher-ag
    skype
    tmux
    trash-cli
    tree
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
  sudo apt-get install -y $package
  echo $package
done


# ===== Custom applications =====

cd ~/opt

# gsettings-info
git clone https://github.com/jmatsuzawa/gsettings-info
ln -sf ~/opt/gsettings-info/gsettings-info ~/bin/gsettings-info

# xkblayout-state
git clone https://github.com/nonpop/xkblayout-state.git
cd xkblayout-state
make
cd ~/opt
ln -sf ~/opt/xkblayout-state/xkblayout-state ~/.i3/scripts/xkblayout-state

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git
fzf/install

# git-credential-helper
git clone git://github.com/pah/git-credential-helper.git
BACKEND=gnome-keyring
cd git-credential-helper/$BACKEND
make
cp git-credential-$BACKEND ~/bin/
cd ~/opt

# fasd
cd ~/opt && tar zxv < <(wget -q -O - https://github.com/clvv/fasd/archive/1.0.1.tar.gz)
cd fasd-1.0.1
sudo make install
cd ~/opt

cd

# ===== Proprietary drivers =====

# Consider configuring drivers in Software & updates -> Drivers

