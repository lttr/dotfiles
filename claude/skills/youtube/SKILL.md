---
name: youtube
description: This skill should be used when the user wants to extract a transcript from a YouTube video, summarize a YouTube video, or critically analyze a YouTube video's claims. Trigger on keywords like "youtube", "transcript", "summarize video", "critique video", or when a YouTube URL is provided.
allowed-tools: Read, Write, Glob, Grep, Task, Bash(cat:*), Bash(ls:*), Bash(yt-dlp:*), Bash(firefox:*), WebFetch
argument-hint: [critique|summarize] <url>
---

# YouTube Transcript & Summary

Input: $ARGUMENTS

## Prerequisites

- `yt-dlp` - transcript extraction
- `firefox` - cookie auth, opening results

## Parse Arguments

- First word is `critique` → **critique mode**, URL is the rest
- First word is `summarize` → **summarize mode**, URL is the rest
- Otherwise → **transcript-only mode**, entire input is the URL

## Extract Transcript

### Download subtitles with yt-dlp

```bash
yt-dlp --cookies-from-browser=firefox --write-auto-sub --write-sub --sub-lang en --skip-download --output "%(title)s.%(ext)s" "VIDEO_URL"
```

If `--cookies-from-browser=firefox` fails, try `chrome`, then no cookies flag.

### Read the transcript

Read the downloaded subtitle file (`.vtt` or `.srt`). The LLM can process VTT/SRT markup directly - no conversion needed.

If mode is **transcript-only**: report file path, language, line count. **Stop here.**

## Summarize or Critique

1. Use WebFetch on the YouTube URL to extract: video title, channel/speaker, description, duration.
2. Read the mode-specific template:
   - **critique mode** → Read `~/dotfiles/claude/skills/youtube/critique.md`
   - **summarize mode** → Read `~/dotfiles/claude/skills/youtube/summarize.md`
3. Generate summary following the template structure.
4. Save to `~/SynologyDrive/moje/AI/summaries/{YYYY-MM-DD}_{slug}.md` (slug: lowercase kebab-case from title, max 60 chars).
5. Clean up the transcript `.txt` file.
6. Open result in Firefox: `firefox "$path" &`
