---
name: transcribe
description: Transcribe audio/video files to text using ElevenLabs Scribe API. Use when user wants to transcribe audio (ogg, mp3, wav, m4a, flac, webm) or video files (mp4, mkv, mov, avi) or voice messages. Trigger on keywords like "transcribe", "voice message", "audio to text", or when an audio/video file path is provided.
allowed-tools: Bash(ffmpeg:*), Bash(curl:*), Bash(jq:*), Bash(rm:*), Bash(mktemp:*), Read, Write
argument-hint: <audio-file> [language-code]
---

# Audio Transcription

Input: $ARGUMENTS

## Prerequisites

- `ffmpeg` - audio conversion
- `ELEVENLABS_API_KEY` env var
- `curl`, `jq`

## Parse Arguments

- First arg: path to audio file (required)
- Second arg: language code (optional, e.g. `cs`, `en`, `es`). If not provided, auto-detect.

## Step 1: Extract Audio / Convert to MP3

ElevenLabs Scribe accepts common formats but works best with MP3. Extract audio (from video) and convert:

```bash
TMPDIR=$(mktemp -d)
ffmpeg -y -i "<input-file>" -vn -acodec libmp3lame -q:a 4 "$TMPDIR/audio.mp3" 2>&1 | tail -3
```

The `-vn` flag strips video, so this works for both audio-only and video files. If the file is already MP3, copy it instead of re-encoding.

## Step 2: Transcribe with ElevenLabs

```bash
TEMP_JSON=$(mktemp)

curl -X POST "https://api.elevenlabs.io/v1/speech-to-text" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" \
    -F "model_id=scribe_v1" \
    -F "file=@$TMPDIR/audio.mp3" \
    ${LANGUAGE_CODE:+-F "language_code=$LANGUAGE_CODE"} \
    -o "$TEMP_JSON" \
    -s

jq -r '.text' "$TEMP_JSON"
```

Check for errors in the response (`.detail` field = API error).

## Step 3: Output

- Print the transcript directly in the conversation
- Save transcript to `<input-file-without-extension>.transcript.txt` next to the original file
- Clean up temp files

## Error Handling

- **Missing ffmpeg**: tell user to install ffmpeg
- **Missing ELEVENLABS_API_KEY**: tell user to set the env var
- **API error**: show the error detail from response
- **Unsupported format**: list supported formats (ogg, mp3, wav, m4a, flac, webm, mp4)
