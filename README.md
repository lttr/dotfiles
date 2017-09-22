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
- git `sudo apt-get install git`
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

## Other things to consider

- sync Dropbox before installation
- check if fonts are linked and installed
- copy /etc/fstab from backup, check mounted disks
- check backups are set up

## Thanks

- [github](http://dotfiles.github.io/)
- [alexbooker/dotfiles](https://github.com/alexbooker/dotfiles)
- [skwp/dotfiles](https://github.com/skwp/dotfiles)
