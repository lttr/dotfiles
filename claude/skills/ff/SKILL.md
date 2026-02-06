---
name: ff
description: Open the last mentioned file in Firefox. Use when user says "ff", "open in firefox", "open in browser", or wants to preview a file in the browser. Also use proactively after generating or editing HTML/SVG/PDF files that benefit from browser preview.
allowed-tools: Bash(firefox:*)
---

# Open File in Firefox

Open the last mentioned file path from the conversation in Firefox.

## Workflow

1. Look through the recent conversation for the last file path that was mentioned, read, edited, or written
2. Run: `firefox "$file_path" &`

## Notes

- If no file was recently mentioned, ask the user which file to open
