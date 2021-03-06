# =================================================================
#                          Gnome desktop
# =================================================================

# disable fancy gnome animations
gsettings set org.gnome.desktop.interface enable-animations false

# disable cursor blinking
gsettings set org.gnome.desktop.interface cursor-blink false

# clock in panel
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface clock-show-date false
gsettings set org.gnome.desktop.interface clock-show-seconds false

# window buttons (pop_os has only close button by default)
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

# desktop background
gsettings set org.gnome.desktop.background show-desktop-icons false
gsettings set org.gnome.desktop.background primary-color '#425265'
gsettings set org.gnome.desktop.background secondary-color '#425265'
gsettings set org.gnome.desktop.background color-shading-type 'solid'

# =================================================================
#                             Theme
# =================================================================

# GTK theme
gsettings set org.gnome.desktop.interface gtk-theme "Pop-slim"
# icon theme
gsettings set org.gnome.desktop.interface icon-theme "Pop"
# shell theme
gsettings set org.gnome.shell.extensions.user-theme name "Pop-dark-slim"
# cursor theme
gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"

# =================================================================
#                              Mouse
# =================================================================

# do not accelerate mouse cursor
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
gsettings set org.gnome.desktop.peripherals.mouse speed 0.6
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

# on touchpad scroll down by sliding fingers up
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# =================================================================
#                            Keyboard
# =================================================================

# use Capslock as an additional Escape
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"

# set prefered keyboard layouts
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'cz+qwerty')]"

# all the shortcuts shortcuts
dconf load / < ~/dotfiles/gnome/keybindings.dconf

# =================================================================
#                            Sounds
# =================================================================

# disable system sounds
gsettings set org.gnome.desktop.sound event-sounds false

# =================================================================
#                            Pop OS
# =================================================================

# window tiling
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Super>Left', '<Super>h']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Super>Right', '<Super>l']"

# =================================================================
#                         Gnome terminal
# =================================================================

# Import terminal settings
# dconf load /org/gnome/terminal/ < ~/dotfiles/gnome/gnome-terminal.dconf

# =================================================================
#                       Default applications
# =================================================================

touch ~/.config/mimeapps.list

xdg-mime default google-chrome.desktop text/html
xdg-mime default google-chrome.desktop x-scheme-handler/http
xdg-mime default google-chrome.desktop x-scheme-handler/https
xdg-mime default google-chrome.desktop x-scheme-handler/about

xdg-mime default org.gnome.gThumb.desktop image/bpm
xdg-mime default org.gnome.gThumb.desktop image/gif
xdg-mime default org.gnome.gThumb.desktop image/ico
xdg-mime default org.gnome.gThumb.desktop image/jpeg
xdg-mime default org.gnome.gThumb.desktop image/jpg
xdg-mime default org.gnome.gThumb.desktop image/png
xdg-mime default org.gnome.gThumb.desktop image/tiff

xdg-mime default inkscape.desktop image/svg+xml

xdg-mime default code.desktop text/plain
xdg-mime default code.desktop application/x-mswinurl
xdg-mime default code.desktop text/markdown
xdg-mime default code.desktop text/x-log

xdg-mime default vlc.desktop video/x-msvideo

# =================================================================
#                            Qt apps
# =================================================================

# Set GTK theme for Qt apps
#   if grep -Fxq "style=GTK+" ~/.config/Trolltech.conf >/dev/null 2>&1
#   then
#       : # "GTK theme for Qt apps already set"
#   else
#       echo "[Qt]" >> ~/.config/Trolltech.conf
#       echo "style=GTK+" >> ~/.config/Trolltech.conf
#       echo "GTK theme for Qt apps set"
#   fi

#   echo "Gnome theme updated"