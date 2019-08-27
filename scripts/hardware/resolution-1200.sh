#!/usr/bin/env bash

# Force the 1920x1200 resolution
xrandr --newmode "1920x1200R"  154.00  1920 1968 2000 2080  1200 1203 1209 1235 +hsync -vsync
xrandr --addmode HDMI-1 "1920x1200R"
xrandr --output HDMI-1 --mode "1920x1200R"