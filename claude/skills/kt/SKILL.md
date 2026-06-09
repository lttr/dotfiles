---
name: kt
description: Open the last mentioned file in neovim inside a new kitty window pane. Use when user says "kt", "open in term", "open in kitty", "open in neovim", "open in nvim", "open neovim in kitty", or wants to edit a file in a terminal split. Also use proactively after generating or editing text files the user will want to review in their editor.
allowed-tools: Bash(bash:*), Bash(kitty:*)
---

# Open File in Kitty + Neovim

Open the last mentioned file path in neovim, inside a new kitty window pane (split within the current OS window).

## Prerequisite

Runs only inside the kitty terminal with remote control enabled (`kitty @` must work). If `kitty @ ls` fails, tell the user this skill is kitty-only and stop.

## Workflow

1. Find the last file path mentioned, read, edited, or written in recent conversation
2. Split into `<dir>` (parent directory, absolute) and `<name>` (filename only)
3. Run:

```bash
bash -c "kitty @ launch --type window --cwd <dir> nvim <name>" &
```

## Rules

- `--type window` — new kitty window pane inside current OS window. NOT `--type tab`. NOT `--type os-window`.
- `--cwd <dir>` — always set, so relative paths and `:!` commands in nvim work naturally.
- Pass plain `<name>` to nvim (not absolute path), since cwd is already set.
- Wrap in `bash -c "..." &` so it backgrounds cleanly and does not block.

## Notes

- If no file was recently mentioned, ask the user which file to open.
- For multiple files: pass them all as args after `nvim` (still inside the same `--cwd`).
