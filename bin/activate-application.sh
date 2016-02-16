#!/bin/bash
if [ `wmctrl -l | grep -c "$2"` != 0 ]  
then
    wmctrl -a "$2"
else
    $1 &
fi
