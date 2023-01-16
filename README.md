# dotfiles

This is a collection of files for configuration and installation of my
development machines. This is a great way how to manage the settings of your
applications, install new machine easily or share the way you work with others.
See more on the links under _Thanks_.

## What is inside

#### Scripts for installing

- applications
  - via apt-get
  - node packages
  - brew packages
- directory structure
- gnome settings
- symbolic links

#### Configuration files

- `antidote` (plugins for zsh)
- `git` (aliases, config)
- `kitty` (terminal with enough tmux like features)
- `neovim` (editor)
- `ranger` (directories browser)
- `rg` (searching program)
- `zsh` (just a better program launcher :)

##### No longer used //why

- `ag` (searching program) // I use ripgrep, it is the fastest
- `antibody` (plugins for zsh) // Superceeded by antidote
- `dunst` (notifications in i3) // only for i3
- `i3` (window manager) // Gnome on PopOS has good workspace and window layout
  support and looks good out of the box
- `kdiff3` (diff program) // Vscode has that, vim has that
- `rofi` (program launcher) // Gnome is enough, maybe Ulauncher is a better fit
  for Gnome
- `tmux` (terminal on the next level) // Terminals can do a lot of what tmux can
- `urxvt` (capable terminal) // Hyper terminal is fast enough now and
  multiplatform
- `hyperterminal` (nice terminal) // Nice but slow
- `vim` (the most ergonomic editor) // I use neovim
- `vim` simulations (ideavim, vrapper) // I use neovim for all work
- `vscode` (editor) // customizable but not enough, fast but not enough,
  integrated but not enough
- `windows` (operating system) // Linux became good for everything work oriented
  tasks

#### Usefull scripts

- for connections
- for environment and hardware setup
- shortcuts for applications

#### Others

- aliases and functions (for command line)
- color schemes
- some stuff for Windows

## How to install

I do not recommend to install it this way. Just browse the repo for inspiration,
rather then installing it completely. This is only for me to remember.

Expects:

- Fresh installation PopOS LTS
- home dir `cd ~`

Run install script (prepares environment, installs requirements and runs the
main install task)

```
git clone https://github.com/lttr/dotfiles
dotfiles/install.sh
```

## Other things to consider after/during installation

### Before install

- Gnome Displays - check resolution of monitor
- install, enable and configure Gnome extensions
  - works best using Firefox (https://extensions.gnome.org)
  - install browser extension - link on top of the page
    - `Dash to panel`
    - `GSconnect`
    - `Bluetooth Quick Connect`
    - `Sound Switcher Indicator` (from https://yktoo.com/en/software/sound-switcher-indicator/)
- upgrade PopOS if needed (`pop-upgrade release upgrade`)

### After install

- install 1Password
  - download .deb (https://1password.com/downloads/linux)
  - multi-factor log in
- install Rambox
- install Darktable
- install VSCode
- log into gh cli
- log into Dropbox, select folders to sync
- set DuckDuckGo as the default search engine, load its configuration via
  bookmarklet (in password manager)
- copy `/etc/fstab` from backup, careful with changing current filesystem root
  partion
- sign into Firefox/Chrome to sync browser settings
- consider disabling slow systemd services
  - e.g. `sudo systemctl disable NetworkManager-wait-online.service`
- update ssh keys (e.g. generate new key for Github, etc.) (https://lukastrumm.com/notes/ssh-keys/, https://github.com/settings/keys)
- list of startup applications (located at `~/.config/autostart/*.desktop`)
- bookmarks in Gnome Files (located at `~/.config/gtk-3/bookmarks` and
  `~/.config/gtk-3/servers`)
- change hostname (`sudo hostname pop-os-something`)

### Automated

- upgrade system (`sudo apt update`, `sudo apt full-upgrade`)

### No longer used configurations

- sync Dropbox before installation
  - Dropbox needs running daemon (`dropbox status`, `dropbox start -i`,
    `dropbox autostart y`)
- change download folder in your browser (I like `~/down`)
- import backuped settings into some applications (e.g. doublecommander)
- enable automatic login in `/etc/gdm3/custom.conf` (in PopOS it can be
  configured in Settings -> Users)
- check appearance settings in `lxappearance` utility
- check backups are set up (I have all work in git or on external drives, that
  are backed up)
- check if fonts are linked and installed

## Installation into VirtualBox

- add Shared folder in settings
- install guest additions (add guest additions from VirtualBox and run
  `VBoxLinuxAdditions.run` as root)
- add user to vboxsf group `sudo usermod -a -G vboxsf lukas`

## Thanks

- [github](http://dotfiles.github.io/)
- [alexbooker/dotfiles](https://github.com/alexbooker/dotfiles)
- [skwp/dotfiles](https://github.com/skwp/dotfiles)
