#!/usr/bin/env bash

# audio-transcribe.sh - Transcribe audio files using ElevenLabs API
# Usage: audio-transcribe.sh <audio-file> [options]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
MODEL_ID="scribe_v1"
LANGUAGE_CODE=""
DIARIZE="false"
TAG_AUDIO_EVENTS="false"
NUM_SPEAKERS=""
OUTPUT_FILE=""

# Help message
show_help() {
    cat << EOF
Usage: $(basename "$0") <audio-file> [options]

Transcribe audio files using ElevenLabs Speech-to-Text API.

Options:
    -o, --output <file>         Output file (default: <audio-file>.txt)
    -l, --language <code>       Language code (e.g., en, es, fr)
    -d, --diarize              Enable speaker identification
    -s, --speakers <num>        Expected number of speakers
    -e, --events               Tag audio events (laughter, applause, etc.)
    -m, --model <model>         Model ID (default: scribe_v1)
    -h, --help                 Show this help message

Examples:
    $(basename "$0") interview.mp3
    $(basename "$0") meeting.wav -d -s 3 -o transcript.txt
    $(basename "$0") podcast.mp4 -l en -e --diarize

EOF
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

AUDIO_FILE="$1"
shift

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -l|--language)
            LANGUAGE_CODE="$2"
            shift 2
            ;;
        -d|--diarize)
            DIARIZE="true"
            shift
            ;;
        -s|--speakers)
            NUM_SPEAKERS="$2"
            shift 2
            ;;
        -e|--events)
            TAG_AUDIO_EVENTS="true"
            shift
            ;;
        -m|--model)
            MODEL_ID="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            show_help
            exit 1
            ;;
    esac
done

# Validate audio file
if [ ! -f "$AUDIO_FILE" ]; then
    echo -e "${RED}Error: Audio file '$AUDIO_FILE' not found${NC}" >&2
    exit 1
fi

# Check for API key
if [ -z "${ELEVENLABS_API_KEY:-}" ]; then
    echo -e "${RED}Error: ELEVENLABS_API_KEY environment variable not set${NC}" >&2
    exit 1
fi

# Set default output file if not specified
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="${AUDIO_FILE%.*}.txt"
fi

echo -e "${GREEN}Transcribing: $AUDIO_FILE${NC}"
echo -e "${YELLOW}Model: $MODEL_ID${NC}"

# Build curl command
CURL_CMD=(
    curl -X POST "https://api.elevenlabs.io/v1/speech-to-text"
    -H "xi-api-key: $ELEVENLABS_API_KEY"
    -F "model_id=$MODEL_ID"
    -F "file=@$AUDIO_FILE"
)

# Add optional parameters
if [ -n "$LANGUAGE_CODE" ]; then
    CURL_CMD+=(-F "language_code=$LANGUAGE_CODE")
    echo -e "${YELLOW}Language: $LANGUAGE_CODE${NC}"
fi

if [ "$DIARIZE" = "true" ]; then
    CURL_CMD+=(-F "diarize=true")
    echo -e "${YELLOW}Speaker diarization: enabled${NC}"
fi

if [ -n "$NUM_SPEAKERS" ]; then
    CURL_CMD+=(-F "num_speakers=$NUM_SPEAKERS")
    echo -e "${YELLOW}Expected speakers: $NUM_SPEAKERS${NC}"
fi

if [ "$TAG_AUDIO_EVENTS" = "true" ]; then
    CURL_CMD+=(-F "tag_audio_events=true")
    echo -e "${YELLOW}Audio event tagging: enabled${NC}"
fi

# Create temporary file for JSON response
TEMP_JSON=$(mktemp)
trap "rm -f $TEMP_JSON" EXIT

echo ""
echo -e "${YELLOW}Sending request to ElevenLabs API...${NC}"

# Execute curl command
if ! "${CURL_CMD[@]}" -o "$TEMP_JSON" -w "\nHTTP Status: %{http_code}\n" 2>&1; then
    echo -e "${RED}Error: Failed to make API request${NC}" >&2
    exit 1
fi

# Check if response is valid JSON
if ! jq empty "$TEMP_JSON" 2>/dev/null; then
    echo -e "${RED}Error: Invalid JSON response from API${NC}" >&2
    cat "$TEMP_JSON" >&2
    exit 1
fi

# Check for API errors
if jq -e '.detail' "$TEMP_JSON" >/dev/null 2>&1; then
    echo -e "${RED}API Error:${NC}" >&2
    jq -r '.detail' "$TEMP_JSON" >&2
    exit 1
fi

# Extract transcript text
echo ""
echo -e "${GREEN}Transcription complete!${NC}"

# Save formatted output
{
    echo "=== Transcription of: $AUDIO_FILE ==="
    echo "Date: $(date)"
    echo "Model: $MODEL_ID"
    echo ""

    # Extract text from response
    if jq -e '.text' "$TEMP_JSON" >/dev/null 2>&1; then
        # Single channel response
        jq -r '.text' "$TEMP_JSON"
    elif jq -e '.channels' "$TEMP_JSON" >/dev/null 2>&1; then
        # Multi-channel response
        jq -r '.channels[] | "=== Channel \(.channel_number) ===\n\(.text)\n"' "$TEMP_JSON"
    else
        echo "Warning: Unexpected response format"
        jq '.' "$TEMP_JSON"
    fi
} > "$OUTPUT_FILE"

echo -e "${GREEN}Transcript saved to: $OUTPUT_FILE${NC}"

# Show word count
WORD_COUNT=$(wc -w < "$OUTPUT_FILE")
echo -e "${YELLOW}Word count: $WORD_COUNT${NC}"

# Optionally show preview
if command -v batcat >/dev/null 2>&1; then
    echo ""
    echo -e "${YELLOW}Preview:${NC}"
    batcat --style=plain --line-range=:20 "$OUTPUT_FILE"
elif command -v bat >/dev/null 2>&1; then
    echo ""
    echo -e "${YELLOW}Preview:${NC}"
    bat --style=plain --line-range=:20 "$OUTPUT_FILE"
else
    echo ""
    echo -e "${YELLOW}Preview (first 10 lines):${NC}"
    head -n 10 "$OUTPUT_FILE"
fi
