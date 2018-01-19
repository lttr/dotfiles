#!/bin/bash
DISPLAY=:0 xrdb -load ~/.Xresources
DISPLAY=:0 urxvtc -e sh -c "zsh" "$@"
if [[ $? -eq 2 ]]; then
	urxvtd -q -o -f
	DISPLAY=:0 urxvtc -e sh -c "zsh" "$@"
fi
