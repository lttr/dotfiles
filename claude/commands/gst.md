---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git branch:*)
description: Display a clean, scannable git status
---

Display a clean, scannable git status.

Parse `git status` output and format as:

```
master (up to date with origin/master)

Modified:
  bootstrap/configuration/symlinks.ts :: <summary>summary of changes inside bootstrap/configuration/symlinks.ts</summary>
  claude/settings.json :: <summary>summary of changes inside claude/settings.json</summary>

Untracked:
  claude/commands/ :: <summary>summary of changes inside claude/commands/ directory</summary>

2 modified, 1 untracked
```

Use minimal colors for terminal use:

- Branch name in green
- Section headers in blue
- Counts in yellow

Keep output compact and easy to scan at a glance.

