---
allowed-tools: Bash(kitty @ launch:*)
description: Fork this session into a new kitty split, leave this one running
---

Fork the current Claude session into a new kitty window (split inside the current OS window) and continue working there. This session stays untouched.

If `$ARGUMENTS` is non-empty, pass it as the opening prompt for the forked window. Run exactly one of:

```bash
# no args — resume the fork, wait for user input
kitty @ launch --type window --cwd "$PWD" claude --resume "$CLAUDE_CODE_SESSION_ID" --fork-session

# with args — fork and kick off with that prompt
kitty @ launch --type window --cwd "$PWD" claude --resume "$CLAUDE_CODE_SESSION_ID" --fork-session "$ARGUMENTS"
```

Then tell the user the fork opened in a new split and they can keep using either window independently.

## Notes

- `--fork-session` copies this session into a fresh session ID, so the new window diverges without affecting this one.
- The fork reads the on-disk transcript, so it includes history up to roughly the last completed turn (the in-flight turn may not be captured).
- `--type window` = split pane in the current OS window. Use `--type os-window` for a separate window, `--type tab` for a new tab.
