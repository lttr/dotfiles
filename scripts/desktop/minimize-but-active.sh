#!/bin/sh

# Get the active window ID
ACTIVE_WINDOW=$(xdotool getactivewindow)

# Get all window IDs and minimize each one except the active window
for WINDOW in $(xdotool search --onlyvisible ".*"); do
    if [ "$WINDOW" != "$ACTIVE_WINDOW" ]; then
        xdotool windowminimize $WINDOW
    fi
done
