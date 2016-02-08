Linux Mint Installation
=======================

## Installation

Install Google Chrome
```
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
sudo dpkg -i google-chrome*.deb
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
