#!/bin/bash

# ElevenLabs Speech-to-Text Script
# Usage: ./aistt.sh [options] <audio_file>
# Options:
#   -r, --raw       Output only the transcription text (no headers)
#   --no-claude     Skip Claude post-processing (enabled by default)
#   --no-copy       Don't copy to clipboard (enabled by default)
#   -h, --help      Show this help message

set -e

# Parse command line options
RAW_OUTPUT=false
USE_CLAUDE=true
COPY_TO_CLIPBOARD=true
AUDIO_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -r|--raw)
            RAW_OUTPUT=true
            shift
            ;;
        --no-claude)
            USE_CLAUDE=false
            shift
            ;;
        --no-copy)
            COPY_TO_CLIPBOARD=false
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options] <audio_file>"
            echo "Options:"
            echo "  -r, --raw       Output only the transcription text (no headers)"
            echo "  --no-claude     Skip Claude post-processing (enabled by default)"
            echo "  --no-copy       Don't copy to clipboard (enabled by default)"
            echo "  -h, --help      Show this help message"
            echo "Supported formats: mp3, wav, m4a, flac, ogg, webm"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$AUDIO_FILE" ]; then
                AUDIO_FILE="$1"
            else
                echo "Error: Multiple audio files specified"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if file argument is provided
if [ -z "$AUDIO_FILE" ]; then
    echo "Usage: $0 [options] <audio_file>"
    echo "Use -h for help"
    exit 1
fi

# Check if file exists
if [ ! -f "$AUDIO_FILE" ]; then
    echo "Error: File '$AUDIO_FILE' not found"
    exit 1
fi

# Check if API key is set
if [ -z "$ELEVENLABS_API_KEY" ]; then
    echo "Error: ELEVENLABS_API_KEY environment variable is not set"
    echo "Set it with: export ELEVENLABS_API_KEY=your_api_key"
    exit 1
fi

# Check file extension
EXT="${AUDIO_FILE##*.}"
if [[ ! "$EXT" =~ ^(mp3|wav|m4a|flac|ogg|webm|MP3|WAV|M4A|FLAC|OGG|WEBM)$ ]]; then
    echo "Error: Supported formats: mp3, wav, m4a, flac, ogg, webm"
    exit 1
fi

if [ "$RAW_OUTPUT" = false ]; then
    echo "Transcribing: $AUDIO_FILE"
    echo "Using ElevenLabs Scribe v1 model..."
fi

# Make API request
RESPONSE=$(curl -s -X POST "https://api.elevenlabs.io/v1/speech-to-text" \
  -H "xi-api-key: $ELEVENLABS_API_KEY" \
  -F "file=@$AUDIO_FILE" \
  -F "model_id=scribe_v1" \
  -F "tag_audio_events=false")

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    echo "Install with: sudo apt install jq (Ubuntu/Debian) or brew install jq (macOS)"
    exit 1
fi

# Check for API errors
if echo "$RESPONSE" | jq -e '.detail' > /dev/null 2>&1; then
    echo "API Error:"
    echo "$RESPONSE" | jq -r '.detail'
    exit 1
fi

# Extract and display transcription
if echo "$RESPONSE" | jq -e '.text' > /dev/null 2>&1; then
    TRANSCRIPTION=$(echo "$RESPONSE" | jq -r '.text')

    # Post-process with Claude if requested
    if [ "$USE_CLAUDE" = true ]; then
        if command -v claude &> /dev/null; then
            if [ "$RAW_OUTPUT" = false ]; then
                echo
                echo "Post-processing with Claude..."
            fi
            LANG_CODE=$(echo "$RESPONSE" | jq -r '.language_code // "unknown"')
            CORRECTED=$(echo "$TRANSCRIPTION" | claude "Correct any transcription errors in this text. The detected language is '$LANG_CODE'. Only output the corrected text, no explanations:")
            TRANSCRIPTION="$CORRECTED"
        else
            echo "Warning: Claude CLI not found, skipping post-processing" >&2
        fi
    fi

    # Output transcription
    if [ "$RAW_OUTPUT" = true ]; then
        echo "$TRANSCRIPTION"
    else
        echo
        echo "Transcription:"
        echo "=============="
        echo "$TRANSCRIPTION"

        # Display additional info if available
        if echo "$RESPONSE" | jq -e '.language_code' > /dev/null 2>&1; then
            LANG=$(echo "$RESPONSE" | jq -r '.language_code')
            echo
            echo "Detected language: $LANG"
        fi
    fi

    # Copy to clipboard if requested
    if [ "$COPY_TO_CLIPBOARD" = true ]; then
        if command -v xsel &> /dev/null; then
            echo "$TRANSCRIPTION" | xsel --clipboard --input
            if [ "$RAW_OUTPUT" = false ]; then
                echo
                echo "Transcription copied to clipboard"
            fi
        else
            echo "Warning: xsel not found" >&2
        fi
    fi
else
    echo "Error: Unexpected response format"
    echo "$RESPONSE"
    exit 1
fi
