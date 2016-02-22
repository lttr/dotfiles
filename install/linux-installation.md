Linux Mint Installation
=======================

## Installation

Install Google Chrome
```
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
sudo dpkg -i google-chrome*.deb
```

newer:
```
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> 
/etc/apt/sources.list.d/google.list'
sudo apt-get update 
sudo apt-get install google-chrome-stable
```

Install Dropbox
[Dropbox helpcenter](https://www.dropbox.com/en/help/246)
```
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
sudo add-apt-repository "deb http://linux.dropbox.com/ubuntu $(lsb_release -sc) main"
sudo apt-get update
sudo apt-get install nautilus-dropbox
```


Probably update apt-get
```
sudo apt-get -f install
sudo apt-get update
sudo apt-get upgrade
```

Install tools
```
sudo add-apt-repository ppa:martin-frost/thoughtbot-rcm
sudo apt-get install -y curl vim git zsh silversearcher-ag xdotool xbindkeys gpick python-setuptools rcm
sudo chsh -s $(which zsh) $(whoami)
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
```

Install git credential helper for gnome
```
sudo apt-get install libgnome-keyring-dev
cd /usr/share/doc/git/contrib/credential/gnome-keyring
sudo make
git config --global credential.helper 
/usr/share/doc/git/contrib/credential/gnome-keyring/git-credential-gnome-keyring
```

Neovim
```
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install -y python-dev python-pip python3-dev python3-pip neovim
```

Trash
```
sudo apt-get install -y trash-cli
sudo mkdir --parent /.Trash && sudo chmod a+rw /.Trash && sudo chmod +t /.Trash
```


## Configuration


### Dotfiles
```
cd ~
git clone https://github.com/lttr/dotfiles.git
ln -s dotfiles/rcrc .rcrc
rcup -v
```

### Environment

Disable blinking cursor
```
gconftool-2 --set /apps/gnome-terminal/profiles/Default/cursor_blink_mode --type string off
```

### Colors

Directory colors
```
wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-light
mv dircolors.ansi-light .dircolors
dircolors .dircolors
```

Terminal colors
```
git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
./set_light.sh
```
### Caps Lock vs Escape
```
/usr/bin/setxkbmap -option 'caps:swapescape'
```

## Some applications installation
```
sudo apt-get update
sudo apt-get dist-upgrade

sudo apt-get install wmctrl
sudo apt-get install autokey-qt
sudo apt-get install krusader
sudo apt-get install kompare
sudo apt-get install vim-gtk
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim
sudo apt-get install nodejs
sudo apt-get install npm
sudo apt-get install git
sudo apt-get install keepass2
sudo apt-get install vlc
sudo apt-get install python-pip
pip install csvkit
pip install subsample
sudo apt-get install qstardict
sudo apt-get install stardict-english-czech
sudo apt-get install stardict-czech
sudo apt-get install lyx freemind jabref

sudo apt-get install silversearcher-ag gnuplot curl vagrant umlet openvpn inkscape viking -y
sudo apt-get install xdotool
sudo apt-get install dos2unix
sudo apt-get install inkscape

sudo apt-get install python python-gtk2 python-xlib python-dbus python-wnck
cd /opt
sudo git clone https://github.com/ssokolow/quicktile
sudo ./quicktile/setup.py install
```

[activace aplikaci](http://superuser.com/questions/16647/custom-hotkey-shortcut-to-open-bring-to-front-an-app)


## Resolution

[xrandr](https://wiki.archlinux.org/index.php/xrandr)
[#Adding_undetected_resolutions](https://wiki.ubuntu.com/X/Config/Resolution/#Adding_undetected_resolutions)
[how-to-add-display-resolution-fo-an-lcd-in-ubuntu-12-04-xrandr-problem](http://askubuntu.com/questions/138408/how-to-add-display-resolution-fo-an-lcd-in-ubuntu-12-04-xrandr-problem)

```
cvt -r 1920 1200 60
xrandr --newmode "1920x1200R"  154.00  1920 1968 2000 2080  1200 1203 1209 1235 +hsync -vsync
xrandr --addmode DVI-I-1 "1920x1200R"
xrandr --output DVI-I-1 --mode "1920x1200R"
```

## Themes

Paper theme
```
sudo add-apt-repository ppa:snwh/pulp
sudo apt-get update && sudo apt-get install paper-icon-theme paper-gtk-theme
```

Gnome keybindings
```
gsettings list-recursively org.gnome.shell.keybindings > gnome-keys-export
```


Set up directories
```
rmdir Downloads Desktop Music Pictures Public Templates Videos
mkdir bin down opt sandbox tasks
```

Set up krusader settings
```
mv ~/.kde/share/config/krusaderrc ~/Dropbox/conf/krusader
ln -s ~/Dropbox/conf/krusader/krusaderrc ~/.kde/share/config/krusaderrc 
mv ~/.kde/share/apps/krusader/krbookmarks.xml ~/Dropbox/conf/krusader
ln -s ~/Dropbox/conf/krusader/krbookmarks.xml ~/.kde/share/apps/krusader/krbookmarks.xml 
mv ~/.kde/share/apps/krusader/krusaderui.rc ~/Dropbox/conf/krusader
ln -s ~/Dropbox/conf/krusader/krusaderui.rc ~/.kde/share/apps/krusader/krusaderui.rc 
mv ~/.kde/share/apps/krusader/useractions.xml ~/Dropbox/conf/krusader
ln -s ~/Dropbox/conf/krusader/useractions.xml ~/.kde/share/apps/krusader/useractions.xml 
```

