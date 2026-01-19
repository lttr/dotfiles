---
created: 2026-01-16
type: plan
status: draft
---

# Consolidate Transcription Scripts

## Goal

Merge `aistt.sh` and `audio-transcribe.sh` into single unified `transcribe` script.

## Current State

| Script | Location | Features |
|--------|----------|----------|
| `aistt.sh` | `scripts/ai-tools/` | Claude post-processing, clipboard copy, raw mode |
| `audio-transcribe.sh` | `scripts/graphics/` | Diarization, events, speakers, language, file output w/ metadata |
| `video-to-mp3.sh` | `scripts/graphics/` | ffmpeg audio extraction (standalone utility) |

**Problem**: Two scripts do the same core task (ElevenLabs STT) with complementary features.

## Steps

1. Create unified `transcribe` script at `scripts/ai-tools/transcribe.sh`
   - Merge all features:
   - `-o, --output <file>` - Output to file
   - `-l, --language <code>` - Language hint
   - `-d, --diarize` - Speaker identification
   - `-s, --speakers <num>` - Expected speakers
   - `-e, --events` - Tag audio events
   - `-c, --claude` - Claude post-processing (opt-in)
   - `--clipboard` - Copy to clipboard (opt-in)
   - `-r, --raw` - Raw output for scripting
   - `-v, --video` - Auto-extract audio from video first

2. Keep `video-to-mp3.sh` as standalone (useful independently)

3. Delete old scripts
   - Remove `scripts/ai-tools/aistt.sh`
   - Remove `scripts/graphics/audio-transcribe.sh`

4. Add alias in `aliases`: `alias stt='transcribe.sh'`

5. Verify with test commands:
   ```bash
   transcribe test.mp3
   transcribe test.mp3 --clipboard --claude
   transcribe meeting.mp3 -d -s 2 -o meeting.txt
   transcribe video.mp4 -v -o transcript.txt
   ```

## Unresolved Questions

None.
