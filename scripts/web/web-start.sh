#!/usr/bin/env bash

name=${1:-"web-sandbox_`date +%Y-%m-%d_%H:%M`"}

browser_exe="firefox"
browser_name="Mozilla Firefox"
editor_exe="nvim"
editor_name="neovim"
port="3003"

cd ~/sandbox

# Initialize a project if it does not exists
if [ -d "$name" ]
then
  echo "Project '$name' already exists"
  cd $name
else
  # https://www.npmjs.com/package/pollinate
  command -v pollinate >/dev/null 2>&1 || { \
    echo >&2 "I require 'pollinate' but it's not installed. Aborting."; exit 1; \
  }

  pollinate ~/code/web-start --name $name >/dev/null

  cd $name

  git init >/dev/null
  git add .
  git commit -m "Initial commit"
fi

# launch editor
bash -c "kitty @ launch --type tab --cwd ~/sandbox/${name} nvim index.html" &

# launch dev server
browser-sync start --server --files . --no-notify --browser $browser_exe --port $port

# Next is some prototype of auto layout (editor to the left, browser to the right)
# However much better is to rely on the window manager to do that
# (currently I use PopOS extention for tiling windows with Win+y shortcut)

# # get width of screen and height of screen
# SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
# SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')
# # new width and height
# W=$(( $SCREEN_WIDTH / 2 ))
# H=$(( $SCREEN_HEIGHT ))
# # moving to the right half of the screen:
# X1=0
# X2=$(( $SCREEN_WIDTH / 2 ))
# Y=0

# echo "Moving $editor_name to position $X1,$Y and resizing to $W,$H"
# echo "Moving $browser_name to position $X2,$Y and resizing to $W,$H"

# launch browser
# bash -c "$browser_exe -new-tab http://localhost:$port" &


# sleep 2

# wmctrl -r "$browser_name" -b remove,maximized_vert,maximized_horz \
#   && wmctrl -r "$browser_name" -e 0,$X2,$Y,$W,$H
# wmctrl -r "$name - $editor_name" -b remove,maximized_vert,maximized_horz \
#   && wmctrl -r "$name - $editor_name" -e 0,$X1,$Y,$W,$H

# bash -c "sleep 2;wmctrl -ia `wmctrl -lx | grep "$name - $editor_name" | awk '{print $1}'`"

