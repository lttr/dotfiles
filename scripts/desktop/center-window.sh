#!/bin/sh

fw=`xdotool getwindowfocus`

# Get display dimensions
eval $(xdotool getwindowgeometry --shell "$fw")

# Unmaximize window
wmctrl -ir "$fw" -b remove,maximized_vert,maximized_horz

# 1200 is width of my centered window
# 1420 is height of my monitor minus 20 px for task bar
# 680 is 2560/2-1200/2
# 1408 is 1440-32 (height of bottom bar)
xdotool windowsize "$fw" 1200 1408
xdotool windowmove "$fw" $(($X + 680)) $(($Y + 32))

