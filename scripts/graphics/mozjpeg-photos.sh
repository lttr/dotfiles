#!/usr/bin/env bash

# Reduces size of photos (converts them in place)

RESOLUTION=2560
QUALITY=90

sharp -i "$@" -o ./ --mozjpeg resize $RESOLUTION $RESOLUTION --quality $QUALITY --fit inside
