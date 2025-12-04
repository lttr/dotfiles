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
- `atuin` (terminal's memory)

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
    - (`GSconnect`)
    - (`Bluetooth Quick Connect`)
    - [`Sound Switcher Indicator`](https://yktoo.com/en/software/sound-switcher-indicator/installation/)
- upgrade PopOS if needed (`pop-upgrade release upgrade`)

### After install

- install [1Password](https://1password.com/downloads/linux), deb
- install ~[Rambox](https://rambox.app/download-linux/)~ [Ferdium](https://ferdium.org/download), deb
- install [Obsidian](https://obsidian.md/download), deb
- install Darktable (Pop Shop, flatpak)
- (log into Dropbox, select folders to sync), I prefer Synology Drive these days
- set DuckDuckGo as the default search engine, load its configuration via
  bookmarklet (in password manager)
- copy `/etc/fstab` from backup, careful with changing current filesystem root
  partion
- sign into Firefox/Chrome to sync browser settings
- consider disabling slow systemd services
  - e.g. `sudo systemctl disable NetworkManager-wait-online.service`
- update ssh keys (e.g. generate new key for Github, etc.)
  (https://lukastrumm.com/notes/ssh-keys/, https://github.com/settings/keys)
  - log into gh cli (`gh auth login`)
  - log into glab cli (`glab auth login`)
  - clone active code repositories
- list of startup applications (located at `~/.config/autostart/*.desktop`)
- bookmarks in Gnome Files (located at `~/.config/gtk-3/bookmarks` and
  `~/.config/gtk-3/servers`)
- change hostname (`hostnamectl set-hostname pop-os-lt-foobar`)

## Thanks

- [github](http://dotfiles.github.io/)
- [alexbooker/dotfiles](https://github.com/alexbooker/dotfiles)
- [skwp/dotfiles](https://github.com/skwp/dotfiles)
