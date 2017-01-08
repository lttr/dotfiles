#!/usr/bin/env bash

# Reduces size of photos (converts them in place)

RESOLUTION=2500
QUALITY=85
# BLUR=0.03
MESSAGE="Really reduce $# photos to ${RESOLUTION}px and ${QUALITY}% quality? (y/n) "

read -p "$MESSAGE" -r

if [[ $REPLY =~ ^[Yy]$ ]]; then
    counter=0
    total_number=$#
    original_size=`du -hc "$@" | tail -n 1 | cut -f 1`
    echo "Original size: $original_size"
    for arg in "$@"; do
        (( counter++ ))
        echo "Reducing ${counter}. (${arg}) out of $total_number photos."

        # resize (reduce longer side to the number)
        # set quality in percent
        # little blur for great size reduction
        # set as progressive jpg
        mogrify \
            -resize $RESOLUTION \
            -quality $QUALITY \
            # -gaussian-blur $BLUR \
            -interlace Plane \
            "$arg"

    done
    final_size=`du -hc "$@" | tail -n 1 | cut -f 1`
    echo
    echo "Processed photos: $counter"
    echo "Original size: $original_size"
    echo "Final size: $final_size"
else
    echo "Abandoned."
fi

