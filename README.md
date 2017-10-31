dotfiles
========

This is a collection of files for configuration and installation of my development machines. This is a great way how to manage the settings of your applications, install new machine easily or share the way you work with others.
See more on the links under _Thanks_.


## What is inside

#### Scripts for installing
- directory structure
- applications
    * via apt-get
    * node packages
    * python packages
    * build from source
- gnome settings
- symbolic links

#### Configuration files
- `ag` (searching program)
- `antibody` (plugins for zsh)
- `dunst` (notifications in i3)
- `vim` simulations (ideavim, vrapper)
- `git` (aliases, config)
- `i3` (window manager)
- `kdiff3` (diff program)
- `ranger` (directories browser)
- `rofi` (program launcher)
- `tmux` (terminal on the next level)
- `urxvt` (capable terminal)
- `vim` (the most ergonomic editor)
- `zsh` (just a better program launcher :)

#### Usefull scripts
- for connections
- for environment and hardware setup
- shortcuts for applications

#### Others
- aliases and functions (for command line)
- color schemes
- some stuff for Windows


## How to install

I do not recommend to install it this way. Just browse the repo for inspiration, rather then installing it completely. This is only for me to remember.

Expects:
- Fresh installation of Ubuntu Gnome 16
- home dir `cd ~`

Clone repo and dependencies:
```
sudo apt-get install -y git curl
git clone --recursive https://github.com/lttr/dotfiles
```

Install everything using _dotfiles_ utility script:
```
./dotfiles/scripts/user/dotfiles.sh install all
```
Or install only symlinks (shortcut version of the utility script)
```
./dotfiles/scripts/user/dotfiles.sh i sym
```

## Other things to consider after installation

- sync Dropbox before installation
  + Dropbox needs running daemon (`dropbox status`, `dropbox start -i`, `dropbox autostart y`)
- check if fonts are linked and installed
- copy `/etc/fstab` from backup, careful with changing current filesystem root partion
- check backups are set up
- sign into Google Chrome to sync browser settings
- check appearance settings in `lxappearance` utility
- enable automatic login in `/etc/gdm3/custom.conf`
- consider disabling slow systemd services 
  + e.g. `sudo systemctl disable NetworkManager-wait-online.service`
- change download folder in your browser (I like `~/down`)
- import backuped settings into some applications (e.g. doublecommander)

## Installation into VirtualBox

- add Shared folder in settings
- install guest additions (add guest additions from VirtualBox and run `VBoxLinuxAdditions.run` as root)
- add user to vboxsf group `sudo usermod -a -G vboxsf lukas`

## Thanks

- [github](http://dotfiles.github.io/)
- [alexbooker/dotfiles](https://github.com/alexbooker/dotfiles)
- [skwp/dotfiles](https://github.com/skwp/dotfiles)
