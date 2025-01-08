#!/bin/sh

fw=`xdotool getwindowfocus`

# Get display dimensions
eval $(xdotool getwindowgeometry --shell "$fw")

# Unmaximize window
wmctrl -ir "$fw" -b remove,maximized_vert,maximized_horz

# Add margins
# width: 2560-2*20=2520
# height: 1440-2*20=1400 
# 32 is height of bottom bar
xdotool windowsize "$fw" 2520 1400
# xdotool windowsize "$fw" 2520 1368

# center window
xdotool windowmove "$fw" $(($X + 20)) $(($Y + 20))
