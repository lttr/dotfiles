---
name: youtube-transcript
description: This skill should be used when the user wants to extract a transcript from a YouTube video, summarize a YouTube video, or critically analyze a YouTube video's claims. Trigger on keywords like "youtube", "transcript", "summarize video", "critique video", or when a YouTube URL is provided.
allowed-tools: Read, Write, Glob, Grep, Task, Bash(cat:*), Bash(ls:*), Bash(yt-dlp:*), Bash(sed:*), Bash(awk:*), Bash(firefox:*)
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

Use a fixed output name to avoid special characters in video titles breaking shell commands:

```bash
rm -rf /tmp/yt-transcript && mkdir -p /tmp/yt-transcript
yt-dlp --cookies-from-browser=firefox --write-auto-sub --write-sub --sub-lang en --skip-download --output "/tmp/yt-transcript/video.%(ext)s" "VIDEO_URL"
```

If `--cookies-from-browser=firefox` fails, try `chrome`, then no cookies flag.

### Convert to plain text

Auto-generated VTT files are extremely verbose (timestamps, positioning, HTML tags, duplicate overlapping lines). Strip them to plain text before reading:

```bash
sed -E '/^WEBVTT/d; /^Kind:/d; /^Language:/d; /^NOTE/d; /^$/d; /^[0-9]{2}:[0-9]{2}/d; /-->/d; s/<[^>]*>//g' /tmp/yt-transcript/video.en.vtt | awk '!seen[$0]++' > /tmp/yt-transcript/transcript.txt
```

This removes metadata/timestamps, strips HTML tags, and deduplicates overlapping lines. Read the resulting `.txt` file.

If mode is **transcript-only**: report file path, language, line count. **Stop here.**

## Summarize or Critique

1. Extract video metadata with yt-dlp (do NOT use WebFetch - YouTube blocks it):
   ```bash
   yt-dlp --cookies-from-browser=firefox --skip-download --print "%(title)s\n%(channel)s\n%(description)s\n%(duration_string)s" "VIDEO_URL"
   ```
2. Read the mode-specific template:
   - **critique mode** → Read `critique.md` (in this skill's directory)
   - **summarize mode** → Read `summarize.md` (in this skill's directory)
3. Generate summary following the template structure.
4. Save to `~/SynologyDrive/moje/AI/summaries/{YYYY-MM-DD}_{slug}.md` (slug: lowercase kebab-case from title, max 60 chars).
5. Clean up the transcript `.txt` file.
6. Open result in Firefox: `firefox "$path" &`
