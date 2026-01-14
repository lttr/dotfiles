#!/usr/bin/env bash
# Custom file suggestion for Claude Code using fd
# Based on LIST_FILES_COMMAND from ~/dotfiles/zshrc
# Receives JSON via stdin: {"query": "partial/path"}
# Outputs newline-separated file paths

query=$(cat | jq -r '.query')

fd --strip-cwd-prefix --hidden --no-ignore \
  --exclude .git \
  --exclude node_modules \
  --exclude build/ \
  --exclude dist/ \
  --exclude .lock \
  --exclude .output \
  --exclude .nuxt \
  2>/dev/null | fzf --filter "$query" | head -15
