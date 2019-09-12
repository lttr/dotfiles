#!/usr/bin/env bash

name=${1:-"web-sandbox_`date +%Y-%m-%d_%H:%M`"}

browser_exe="firefox"
browser_name="Mozilla Firefox"
editor_exe="code"
editor_name="Visual Studio Code"
port="3003"

cd ~/sandbox

command -v pollinate >/dev/null 2>&1 || { \
  echo >&2 "I require 'pollinate' but it's not installed. Aborting."; exit 1; \
}

pollinate ~/code/web-start --name $name

cd $name

git init
git add .
git commit -m "Initial commit"

# get width of screen and height of screen
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')
# new width and height
W=$(( $SCREEN_WIDTH / 2 ))
H=$(( $SCREEN_HEIGHT ))
# moving to the right half of the screen:
X1=0
X2=$(( $SCREEN_WIDTH / 2 ))
Y=0

echo "Moving $editor_name to position $X1,$Y and resizing to $W,$H"
echo "Moving $browser_name to position $X2,$Y and resizing to $W,$H"

bash -c "sleep 3; $browser_exe -new-tab http://localhost:$port" &

$editor_exe .
$editor_exe --reuse-window index.html style.css script.js

sleep 2

wmctrl -r "$browser_name" -b remove,maximized_vert,maximized_horz \
  && wmctrl -r "$browser_name" -e 0,$X2,$Y,$W,$H
wmctrl -r "$name - $editor_name" -b remove,maximized_vert,maximized_horz \
  && wmctrl -r "$name - $editor_name" -e 0,$X1,$Y,$W,$H

bash -c "sleep 2;wmctrl -ia `wmctrl -lx | grep "$name - $editor_name" | awk '{print $1}'`"

browser-sync start --server --files . --no-notify --browser $browser_exe --port $port --no-open
