#!/usr/bin/env bash

# Reduces size of photos (converts them in place)

RESOLUTION=4000
QUALITY=95

sharp -i "$@" -o ./ resize $RESOLUTION $RESOLUTION --quality $QUALITY --fit inside --chromaSubsampling '4:4:4' --withMetadata
