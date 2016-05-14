# =================================================================
#                          Gnome desktop
# =================================================================

# disable fancy gnome animations
gsettings set org.gnome.desktop.interface enable-animations false

# disable cursor blinking
gsettings set org.gnome.desktop.interface cursor-blink false

# do not accelerate mouse cursor
gsettings set org.gnome.desktop.peripherals.mouse speed "-1"


# =================================================================
#                         Gnome terminal
# =================================================================


rg.gnome.Terminal.Legacy.Settings
# Hide menu
gsettings set "org.gnome.Terminal.Legacy.Settings" default-show-menubar false
gsettings set org.gnome.Terminal.Legacy.Keybindings paste '<Primary><Shift>v'
profile=$(gsettings get org.gnome.Terminal.ProfilesList default)
profile=${profile:1:-1} # remove leading and trailing single quotes
