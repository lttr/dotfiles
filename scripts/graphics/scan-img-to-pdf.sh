#!/usr/bin/env bash

# Reduces size of photos (converts them in place)

RESOLUTION=1920
QUALITY=82

# resize (reduce longer side to the number)
# set quality in percent
# reset orientation exif information and rotate the image if necessary
# set as progressive jpg
# optionally strip exif information
convert \
    -resize "${RESOLUTION}x${RESOLUTION}>" \
    -quality $QUALITY \
    -auto-orient \
    -interlace Plane \
    -sharpen 5
    -strip
    -auto-level
    "$@"

