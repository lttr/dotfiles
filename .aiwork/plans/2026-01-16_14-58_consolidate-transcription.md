# Consolidate Transcription Scripts

## Current State

| Script | Location | Features |
|--------|----------|----------|
| `aistt.sh` | `scripts/ai-tools/` | Claude post-processing, clipboard copy, raw mode |
| `audio-transcribe.sh` | `scripts/graphics/` | Diarization, events, speakers, language, file output w/ metadata |
| `video-to-mp3.sh` | `scripts/graphics/` | ffmpeg audio extraction (standalone utility) |

**Problem**: Two scripts do the same core task (ElevenLabs STT) with complementary features.

## Plan

### 1. Create unified `transcribe` script
Location: `scripts/ai-tools/transcribe.sh`

Merge all features:
- `-o, --output <file>` - Output to file
- `-l, --language <code>` - Language hint
- `-d, --diarize` - Speaker identification
- `-s, --speakers <num>` - Expected speakers
- `-e, --events` - Tag audio events
- `-c, --claude` - Claude post-processing (opt-in)
- `--clipboard` - Copy to clipboard (opt-in)
- `-r, --raw` - Raw output for scripting
- `-v, --video` - Auto-extract audio from video first

### 2. Keep `video-to-mp3.sh` as standalone
Useful independently, stays in `scripts/graphics/`

### 3. Delete old scripts
- Remove `scripts/ai-tools/aistt.sh`
- Remove `scripts/graphics/audio-transcribe.sh`

### 4. Add alias
In `aliases`: `alias stt='transcribe.sh'`

## Files to Modify
- `scripts/ai-tools/transcribe.sh` (create)
- `scripts/ai-tools/aistt.sh` (delete)
- `scripts/graphics/audio-transcribe.sh` (delete)
- `aliases` (add stt alias)

## Verification
```bash
transcribe test.mp3
transcribe test.mp3 --clipboard --claude
transcribe meeting.mp3 -d -s 2 -o meeting.txt
transcribe video.mp4 -v -o transcript.txt
```
