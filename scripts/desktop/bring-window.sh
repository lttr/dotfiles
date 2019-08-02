#!/bin/bash

if [ $# -ne 1 ];then
  echo -e "Usage: `basename $0` PROGRAM_NAME\n
           For example:\n\t
           '`basename $0` gnome-terminal' for Terminal\n\t
           '`basename $0` firefox' for Firefox\n\t
           '`basename $0` chromium-browser' for Chromium\n\t..."
  exit 1
fi

pids=" $(pidof $@) "

if [ "$pids" = "  " ]; then # the string "  " contain two spaces
    echo "There is no program named '$@' opened at the moment."
    exit 1
fi

wmctrl -lp | while read identity desktop_number PID window_title; do
    if [ "${pids/ $PID }" != "$pids" ]; then
        wmctrl -ia $identity
    fi
done