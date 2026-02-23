---
name: youtube-transcript
description: This skill should be used when the user wants to extract a transcript from a YouTube video, summarize a YouTube video, or critically analyze a YouTube video's claims. Trigger on keywords like "youtube", "transcript", "summarize video", "critique video", or when a YouTube URL is provided.
allowed-tools: Read, Write, Glob, Grep, Task, Bash(cat:*), Bash(ls:*), Bash(yt-dlp:*), Bash(deno:*), Bash(firefox:*), Bash(mkdir:*)
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

## Step 1: Download subtitles + metadata (single yt-dlp call)

Combine subtitle download and metadata extraction into one call. Use a fixed output name to avoid special characters in video titles breaking shell commands:

```bash
mkdir -p /tmp/yt-transcript
yt-dlp --cookies-from-browser=firefox --write-auto-sub --write-sub --sub-lang en --skip-download --force-overwrites --output "/tmp/yt-transcript/video.%(ext)s" --print "%(title)s\n%(channel)s\n%(description)s\n%(duration_string)s" "VIDEO_URL"
```

If `--cookies-from-browser=firefox` fails, try `chrome`, then no cookies flag.

In parallel (if summarize/critique mode), also create the output directory:

```bash
mkdir -p ~/SynologyDrive/moje/AI/summaries
```

## Step 2: Convert VTT to plain text

Auto-generated VTT files are extremely verbose (timestamps, positioning, HTML tags, duplicate overlapping lines). Strip them to plain text:

```bash
deno run --allow-read --allow-write ~/dotfiles/claude/skills/youtube-transcript/vtt-to-text.ts /tmp/yt-transcript/video.en.vtt /tmp/yt-transcript/transcript.txt
```

Read the resulting `.txt` file.

If mode is **transcript-only**: report file path, language, line count. **Stop here.**

## Step 3: Delegate writing to Sonnet subagent

Use the Task tool with `model: sonnet` and `subagent_type: general-purpose`. Pass **everything inline** in the prompt so the subagent needs only a single Write tool call:

- The full transcript text (paste it into the prompt)
- The video metadata (title, channel, duration)
- The template (copy from below)
- The computed output file path
- Today's date

The subagent prompt should contain all data and end with: "Write the summary to {path} using the Write tool. Do not read any files - everything you need is above."

### Output path

`~/SynologyDrive/moje/AI/summaries/{YYYY-MM-DD}_{slug}.md` (slug: lowercase kebab-case from title, max 60 chars)

### Summarize template

```
---
created: {date}
type: summary
source: {url}
speaker: {name}
event: {channel}
---

## Overview

2-3 sentences: video length, speaker/channel, core topic/thesis.

## Key Findings

- Concise bullet points capturing the most important takeaways
- Focus on actionable insights and novel information
- 5-15 bullets depending on video length
```

### Critique template

Read `critique.md` in this skill's directory for the full critique template with examples.

## Step 4: Cleanup, report, and open

1. Clean up: `rm /tmp/yt-transcript/transcript.txt`
2. **Print key findings in chat** - show the Overview and Key Findings sections directly in the conversation so the user doesn't have to open the file to see the result.
3. Open result in Firefox: `firefox "$path" &`
