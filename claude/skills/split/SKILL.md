---
name: split
description: Fork the current Claude session into a new kitty split (new session ID), leaving this session untouched. Use when the user says "split", "branch this", "fork this session", "open this in a new window", or wants to continue a parallel conversation in a separate kitty pane. Kitty-only.
allowed-tools: Bash(kitty @ launch:*), Bash(kitty @ ls:*)
---

# Split — Fork Session into a New Kitty Pane

Fork the current Claude session into a new kitty window (split inside the current OS window) and continue working there. This session stays untouched.

## Prerequisite

Runs only inside the kitty terminal with remote control enabled (`kitty @` must work). If `kitty @ ls` fails, tell the user this skill is kitty-only and stop.

## Workflow

1. If arguments were given, use them as the opening prompt for the forked window.
2. Run exactly one of:

```bash
# no args — resume the fork, wait for user input
kitty @ launch --type window --cwd "$PWD" claude --dangerously-skip-permissions --resume "$CLAUDE_CODE_SESSION_ID" --fork-session

# with args — fork and kick off with that prompt
kitty @ launch --type window --cwd "$PWD" claude --dangerously-skip-permissions --resume "$CLAUDE_CODE_SESSION_ID" --fork-session "<arguments>"
```

3. Tell the user the fork opened in a new split and they can keep using either window independently.

## Notes

- `--fork-session` copies this session into a fresh session ID, so the new window diverges without affecting this one.
- The fork reads the on-disk transcript, so it includes history up to roughly the last completed turn (the in-flight turn may not be captured).
- `--type window` = split pane in the current OS window. Use `--type os-window` for a separate window, `--type tab` for a new tab.
- `$CLAUDE_CODE_SESSION_ID` is set by Claude Code in the shell; no need to look it up.
