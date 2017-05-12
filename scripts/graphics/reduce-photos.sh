#!/usr/bin/env bash

# Reduces size of photos (converts them in place)

RESOLUTION=1920
QUALITY=82
MESSAGE="Really reduce $# photos to ${RESOLUTION}px and ${QUALITY}% quality? (y/n) "

if [[ $# -eq 0 ]]; then
    echo "No arguments supplied."
    exit 1
fi

if [[ $1 = "-y" ]]; then
    REPLY=y
    shift
else
    read -p "$MESSAGE" -r
fi

if [[ $# -eq 0 ]]; then
    echo "No arguments supplied."
    exit 1
fi

if [[ $REPLY =~ ^[Yy]$ ]]; then
    counter=0
    total_number=$#
    original_size=`du -hc "$@" | tail -n 1 | cut -f 1`
    echo "Original size: $original_size"

    if [[ $1 = "-strip" ]]; then
        STRIP=-strip
        shift
    fi
    for arg in "$@"; do
        (( counter++ ))
        echo "Reducing ${counter}. (${arg}) out of $total_number photos."

        # resize (reduce longer side to the number)
        # set quality in percent
        # reset orientation exif information and rotate the image if necessary
        # set as progressive jpg
        # optionally strip exif information
        mogrify \
            -resize "${RESOLUTION}x${RESOLUTION}>" \
            -quality $QUALITY \
            -auto-orient \
            -interlace Plane \
            "$STRIP" \
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

