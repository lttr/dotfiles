---
name: note
description: Save a quick note to ~/notes/inbox as a markdown file. Use when user says "/note", "save note", "jot this down", "add to inbox".
allowed-tools: Write
---

# Save Note to Inbox

Write note to `~/notes/inbox/<Title>.md`.

- Title: from `/note Title :: body` split, else infer 3–7 words from content.
- Strip filesystem-unsafe chars from filename: `/ \ : * ? " < > |`.
- Body: raw text as-is. No frontmatter, no timestamps.
- On collision, suffix `-2`, `-3`, ...
- Reply with saved path.
