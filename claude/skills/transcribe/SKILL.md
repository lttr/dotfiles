---
name: transcribe
description: Transcribe audio/video files to text using ElevenLabs Scribe API. Use when user wants to transcribe audio (ogg, mp3, wav, m4a, flac, webm) or video files (mp4, mkv, mov, avi) or voice messages. Trigger on keywords like "transcribe", "voice message", "audio to text", or when an audio/video file path is provided.
allowed-tools: Bash(ffmpeg:*), Bash(curl:*), Bash(jq:*), Bash(rm:*), Bash(mktemp:*), Read, Write
argument-hint: <audio-file> [mode] [language-code]
---

# Audio Transcription

Input: $ARGUMENTS

## Prerequisites

- `ffmpeg` - audio conversion
- `ELEVENLABS_API_KEY` env var
- `curl`, `jq`

## Parse Arguments

- **First arg**: path to audio file (required).
- **mode** (optional, default `text`): one of `text` | `context` | `timings` | `diarize`. See Modes below. Infer from how the user phrased the request if not given explicitly.
- **language-code** (optional, e.g. `cs`, `en`, `es`): if not provided, auto-detect.
- **context terms** (mode `context`): special words/names/jargon the user mentions — pass as `keyterms`.

## Modes

| Mode | API flags | Output |
|---|---|---|
| `text` (default) | `tag_audio_events=false` | Clean prose. No `(laugh)` tags. Post-strip filler words (ehm, uh, um, hmm, eh) and stray audio-event parens. |
| `context` | `tag_audio_events=false` + `keyterms` for special vocab | Same clean prose, biased toward the supplied terms. Optionally fix domain spellings yourself after the fact. |
| `timings` | `timestamps_granularity=word` | Transcript plus per-segment `[mm:ss]` timestamps. |
| `diarize` | `diarize=true`, optional `num_speakers=N` | Speaker-labeled transcript (`Speaker 1: ...`). If the user names who is who, relabel accordingly. |

`tag_audio_events` defaults to `true` at the API; we turn it off except when the user explicitly wants events kept.

## Step 1: Extract Audio / Convert to MP3

ElevenLabs Scribe works best with MP3. The `-vn` flag strips video, so this handles both audio and video. If the input is already MP3, skip re-encoding and use it directly.

```bash
TMPDIR=$(mktemp -d)
ffmpeg -y -i "<input-file>" -vn -acodec libmp3lame -q:a 4 "$TMPDIR/audio.mp3" 2>&1 | tail -3
```

## Step 2: Transcribe with ElevenLabs

Base call. Add the mode-specific `-F` flags from the table.

```bash
TEMP_JSON=$(mktemp)

curl -X POST "https://api.elevenlabs.io/v1/speech-to-text" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" \
    -F "model_id=scribe_v2" \
    -F "file=@$TMPDIR/audio.mp3" \
    ${LANGUAGE_CODE:+-F "language_code=$LANGUAGE_CODE"} \
    -F "tag_audio_events=false" \
    -o "$TEMP_JSON" \
    -s

# mode=context, repeat -F per term:  -F "keyterms=Drizzle" -F "keyterms=Nitro"
# mode=timings:                      -F "timestamps_granularity=word"
# mode=diarize:                      -F "diarize=true"   (+ -F "num_speakers=2" if known)
```

Check for errors first: a `.detail` field in the response means an API error — surface it.

## Step 3: Build Output Per Mode

Inspect `.words[]`: each has `text`, `start`, `end`, `type` (`word|spacing|audio_event`), and `speaker_id` (when diarized).

- **text / context**: take `.text`, then strip standalone filler tokens (`ehm`, `uh`, `um`, `hmm`, `eh`, Czech `ee`, `éé`) and any leftover `(...)` audio-event parens. Tidy doubled spaces.
  ```bash
  jq -r '.text' "$TEMP_JSON"
  ```
- **timings**: group `.words[]` into sentence/pause segments, prefix each with `[mm:ss]` from the segment's first `start`.
  ```bash
  jq -r '.words[] | select(.type=="word") | "\(.start)\t\(.text)"' "$TEMP_JSON"
  ```
- **diarize**: walk `.words[]` in order, start a new line whenever `speaker_id` changes, prefix `Speaker N:`.
  ```bash
  jq -r '.words[] | select(.type=="word") | "\(.speaker_id)\t\(.text)"' "$TEMP_JSON"
  ```

## Step 4: Save & Clean Up

- Print the transcript in the conversation.
- Save to `<input-file-without-extension>.transcript.txt` next to the original (suffix with mode if multiple, e.g. `.diarize.txt`).
- Remove temp files (`$TMPDIR`, `$TEMP_JSON`).

## Error Handling

- **Missing ffmpeg**: tell user to install ffmpeg.
- **Missing ELEVENLABS_API_KEY**: tell user to set the env var.
- **API error**: show the `.detail` from the response.
- **Unsupported format**: list supported formats (ogg, mp3, wav, m4a, flac, webm, mp4).
