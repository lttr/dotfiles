#!/usr/bin/env bash

# Extract MP3 audio from video files
# Usage: video-to-mp3.sh <input-file> [output-file]
# Supports: mp4 and other ffmpeg-compatible video formats

set -euo pipefail

# Check if ffmpeg is available
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed"
    exit 1
fi

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input-file> [output-file]"
    echo "Example: $0 video.mp4"
    echo "Example: $0 video.mp4 audio.mp3"
    exit 1
fi

INPUT="$1"

# Check if input file exists
if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found"
    exit 1
fi

# Determine output filename
if [ $# -ge 2 ]; then
    OUTPUT="$2"
else
    # Remove extension and add .mp3
    OUTPUT="${INPUT%.*}.mp3"
fi

# Extract audio
echo "Extracting audio from '$INPUT' to '$OUTPUT'..."
ffmpeg -i "$INPUT" -vn -acodec libmp3lame -q:a 2 "$OUTPUT"

if [ $? -eq 0 ]; then
    echo "✓ Successfully created: $OUTPUT"
else
    echo "✗ Failed to extract audio"
    exit 1
fi
