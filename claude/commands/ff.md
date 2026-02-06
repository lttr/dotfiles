---
description: Open the last mentioned file in Firefox
allowed-tools: Bash(firefox:*)
---

## Your task

Open the last mentioned file path from the conversation in Firefox.

1. Look through the recent conversation for the last file path that was mentioned, read, edited, or written
2. Run: `firefox "$file_path" &`

If no file was recently mentioned, ask the user which file to open.
