#!/bin/bash

# Install Paper theme
sudo add-apt-repository -y ppa:snwh/pulp
sudo apt-get update
sudo apt-get install -y paper-icon-theme paper-gtk-theme

# Install shell extension tool
wget -O ~/bin/shell-extension-install https://raw.githubusercontent.com/NicolasBernaerts/ubuntu-scripts/master/ubuntugnome/gnome-extension/shell-extension-install
chmod +x ~/bin/shell-extension-install

GNOME_VERSION=3.16

# User themes
# https://extensions.gnome.org/extension/19/user-themes/
shell-extension-install $GNOME_VERSION 19

# Native window placement in overview
# https://extensions.gnome.org/extension/18/native-window-placement/
shell-extension-install $GNOME_VERSION 18

# Skype integration
# https://extensions.gnome.org/extension/696/skype-integration/
shell-extension-install $GNOME_VERSION 696

# Top Icons Plus
# https://extensions.gnome.org/extension/1031/topicons/
shell-extension-install $GNOME_VERSION 1031

# Drop Down Terminal
# https://extensions.gnome.org/extension/442/drop-down-terminal/
shell-extension-install $GNOME_VERSION 442

# Grub reboot
# https://extensions.gnome.org/extension/893/grub-reboot/
shell-extension-install $GNOME_VERSION 893

# Panel doclet
# https://extensions.gnome.org/extension/105/panel-docklet/
shell-extension-install $GNOME_VERSION 105

# Laine volume control
# https://extensions.gnome.org/extension/937/laine/
shell-extension-install $GNOME_VERSION 937

# Services systemd
# https://extensions.gnome.org/extension/1034/services-systemd/
shell-extension-install $GNOME_VERSION 1034

# Task bar
# https://extensions.gnome.org/extension/584/taskbar/
shell-extension-install $GNOME_VERSION 584

# Mmod panel
# https://extensions.gnome.org/extension/898/mmod-panel/
shell-extension-install $GNOME_VERSION 898

# Put windows
# https://extensions.gnome.org/extension/39/put-windows/
shell-extension-install $GNOME_VERSION 39

# Activities configurator
# https://extensions.gnome.org/extension/358/activities-configurator/
shell-extension-install $GNOME_VERSION 358

# Buttom panel
# https://extensions.gnome.org/extension/949/bottompanel/
shell-extension-install $GNOME_VERSION 949


# Configuration

# shell theme
gsettings set org.gnome.shell.extensions.user-theme name "Paper"
# cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "Paper"
# gtk theme
gsettings set org.gnome.desktop.interface gtk-theme "Paper"
# icon theme
gsettings set org.gnome.desktop.interface icon-theme "Paper"


# Restart Gnome shell
gnome-shell --replace &


