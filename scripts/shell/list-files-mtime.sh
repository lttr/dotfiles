#!/usr/bin/env bash
# List files under CWD, newest (mtime) first.
# Single source of truth for fzf Ctrl-T (zshrc) and Claude Code's @ file picker.
fd --strip-cwd-prefix --hidden --no-ignore \
  --exclude .git \
  --exclude node_modules \
  --exclude build/ \
  --exclude dist/ \
  --exclude .lock \
  --exclude .nuxt \
  --exclude .output \
  --exclude .claude/worktrees \
  -0 2>/dev/null \
  | xargs -0 -r stat --format='%Y %n' | sort -rn | cut -d' ' -f2-
