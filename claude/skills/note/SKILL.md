---
name: note
description: Save a quick note to ~/notes/inbox as a markdown file. Use when user says "/note", "save note", "jot this down", "add to inbox".
allowed-tools: Write, Skill
---

# Save Note to Inbox

Write note to `~/notes/inbox/<Title>.md`.

- Title: from `/note Title :: body` split, else infer 3–7 words from content.
- Strip filesystem-unsafe chars from filename: `/ \ : * ? " < > |`.
- Body: raw text as-is. No frontmatter, no timestamps.
- No H1 heading when it would just repeat the filename; start with the body.
- Tags (e.g. `#generated`) go at the top of the note, on the first line.
- On collision, suffix `-2`, `-3`, ...
- Reply with saved path.
- When drafting or rephrasing the note content (not just saving verbatim text), invoke the `my-writing-style` skill first.
