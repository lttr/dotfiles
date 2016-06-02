#!/usr/bin/env bash

# Scroll down
if [[ "${BLOCK_BUTTON}" -eq 4 ]]; then
	amixer -D pulse sset Master 5%+
# Middle click
elif [[ "${BLOCK_BUTTON}" -eq 2 ]]; then
	amixer -D pulse sset Master toggle
# Scroll up
elif [[ "${BLOCK_BUTTON}" -eq 5 ]]; then
	amixer -q sset Capture 5%-
fi

vol=$(/usr/share/i3blocks/volume 5 pulse)

if [[ $vol == "MUTE" ]]; then
	echo 
elif [[ $vol -le 20 ]]; then
	echo  ${vol::-1}
else
	echo  ${vol::-1}
fi
