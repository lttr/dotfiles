---
name: kp
description: Paste a shell command into a new kitty window pane at the shell prompt, without running it, so the user can review and press Enter. Use when user says "kp", "kitty paste", "paste it in a split", "send to terminal", or asks to run a command themselves. Also use proactively whenever handing the user a multi-line shell command, since copying it from the terminal adds line breaks that break zsh.
---

# Paste Command into Kitty Split

Open a new kitty window pane and paste the command at its shell prompt. Nothing is executed; the user reviews it and presses Enter.

## Prerequisites

- kitty with remote control enabled (`kitty @ ls` must work); otherwise falls back to `wl-copy` (Wayland) for the clipboard
- The skill opens the pane itself; the user's shell must support bracketed paste (zsh and bash do)

## Workflow

1. Take the command: the one the user asked for, or the last shell command given in the conversation
2. Pick the cwd: the directory the command should run in (default: current project directory)
3. Run, with the command verbatim inside a quoted heredoc:

```bash
$CLAUDE_SKILL_DIR/kp.sh <cwd> <<'CMD'
<command>
CMD
```

## Rules

- Quoted heredoc delimiter (`'CMD'`) so nothing is expanded or escaped. If the command itself contains a line `CMD`, pick another delimiter.
- Paste exactly what the user should run. No comments or placeholders they have to edit, unless unavoidable (then say so).
- The script uses bracketed paste and strips trailing newlines, so multi-line commands land as one editable buffer.
- If kitty remote control is unavailable, the script copies to the clipboard via `wl-copy` instead; tell the user to paste with ctrl+shift+v.
