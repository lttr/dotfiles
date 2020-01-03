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
- `vim` simulations (ideavim, vrapper)
- `git` (aliases, config)
- `ranger` (directories browser)
- `vim` (the most ergonomic editor)
- `zsh` (just a better program launcher :)

##### No longer used //why
- `dunst` (notifications in i3) // only for i3
- `i3` (window manager) // Gnome on PopOS has good workspace and window layout support and looks good out of the box
- `kdiff3` (diff program) // Vscode has that
- `rofi` (program launcher) // Gnome is enough, maybe Ulauncher is a better fit for Gnome
- `tmux` (terminal on the next level) // I only need tabs: Hyper terminal is multiplatform and configuration is easier
- `urxvt` (capable terminal) // Hyper terminal is fast enough now and multiplatform

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
- Fresh installation of PopOS 19.04
- home dir `cd ~`

Clone repo and dependencies:
```
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

- upgrade system (`sudo apt update`, `sudo apt full-upgrade`, `pop-upgrade release upgrade systemd`)
- sync Dropbox before installation
  + Dropbox needs running daemon (`dropbox status`, `dropbox start -i`, `dropbox autostart y`)
- check if fonts are linked and installed
- copy `/etc/fstab` from backup, careful with changing current filesystem root partion
- check backups are set up
- sign into Google Chrome to sync browser settings
- check appearance settings in `lxappearance` utility
- enable automatic login in `/etc/gdm3/custom.conf` (in PopOS it can be configured in Settings -> Users)
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
