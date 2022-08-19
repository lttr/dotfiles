#! /bin/sh
fw=`xdotool getwindowfocus`
# 1200 is width of my centered window
# 1420 is height of my monitor minus 20 px for task bar
# 680 is 2560/2-1200/2
xdotool windowsize "$fw" 1200 1420
xdotool windowmove "$fw" 680 -20

