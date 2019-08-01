#!/usr/bin/env bash

#
# Setup keyboard, monitors and other hardware
#


# =================================================================
#                            Keyboard
# =================================================================

# Primary keyboard: US, alternative Czech, both qwerty
setxkbmap -layout "us,cz" -variant "basic,qwerty"

# Left Alt + Left Shift for keyboard switch
setxkbmap -option grp:lalt_lshift_toggle

# Make Capslock an additional Escape
setxkbmap -option caps:escape

# Force numlock to be on
numlockx


# =================================================================
#                             Mouse
# =================================================================

if [[ $(hostname) == 'lukas-pc-ubuntu' ]]; then
    # Remap forward mouse key to be back, too
    # Source: http://askubuntu.com/questions/492744/how-do-i-automatically-remap-buttons-on-my-mouse-at-startup
    mouse_id=$(xinput | grep "USB Gaming Mouse" | grep pointer | head -1 | awk -F= '{print substr($2,1,2)}')
    xinput set-button-map $mouse_id 1 2 3 4 5 6 7 8 8
fi


# =================================================================
#                            Monitor
# =================================================================

if [[ $(hostname) == 'lukas-pc-ubuntu' ]]; then
    # Force the 1920x1200 resolution
    xrandr --newmode "1920x1200R"  154.00  1920 1968 2000 2080  1200 1203 1209 1235 +hsync -vsync
    xrandr --addmode DVI-I-1 "1920x1200R"
    xrandr --output DVI-I-1 --mode "1920x1200R"
fi

if [[ $(hostname) == 'lttr-pop-os' ]]; then
    # Force the 1920x1200 resolution
    xrandr --newmode "1920x1200R"  154.00  1920 1968 2000 2080  1200 1203 1209 1235 +hsync -vsync
    xrandr --addmode HDMI-1 "1920x1200R"
    xrandr --output HDMI-1 --mode "1920x1200R"
fi


# =================================================================
#                             Disks
# =================================================================

# ===== Setup data partition  =====
# (just a reminder)
# sudo blkid -> copy UUID
# sudo vi /etc/fstab -> add lines:
#   # my data partition
#   UUID=8C5E1F1B5E1EFDA0 /media/data ntfs-3g defaults,windows_names,locale=cs_CZ.utf8,uid=1000,gid=1000,umask=033 0 0
# sudo mount -a -> mount already without reboot

