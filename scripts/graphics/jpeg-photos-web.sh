#!/usr/bin/env bash

# Reduces size of photos (converts them in place)

RESOLUTION=1920
QUALITY=78

sharp -i "$@" -o ./ --mozjpeg resize $RESOLUTION $RESOLUTION --quality $QUALITY --fit inside
