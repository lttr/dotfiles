#!/usr/bin/env bash

if [ $(wmctrl -l | grep -ic "$1") -gt 0 ]  
then
    i3-msg "[class=\"(?i)$1\"] move workspace current"
else
    $1 &
fi
