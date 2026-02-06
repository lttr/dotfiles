---
name: scr
description: Read the last screenshot from ~/Pictures/Screenshots. Use when user says "screenshot", "scr", "last screenshot", or references a screen capture they just took. Also use proactively when the user seems to be referencing visual content they captured.
---

# Last Screenshot

Read the most recent screenshot from `~/Pictures/Screenshots/`.

## Workflow

1. Find the latest screenshot:

```bash
ls -t ~/Pictures/Screenshots/ | head -1
```

2. Read it using the Read tool:

```
Read ~/Pictures/Screenshots/<filename>
```

3. Describe or act on the screenshot content based on the user's request.

## Notes

- Screenshots are saved by the Gnome screenshot utility
- Filename pattern: `Screenshot from YYYY-MM-DD HH-MM-SS.png`
- If no screenshots exist, inform the user
