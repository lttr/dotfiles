#!/usr/bin/env bash
# Custom file suggestion for Claude Code's @ picker.
# Receives JSON via stdin: {"query": "partial/path"}
# Outputs newline-separated file paths, newest (mtime) first.
# File list is shared with fzf Ctrl-T via scripts/shell/list-files-mtime.sh.

query=$(cat | jq -r '.query')

"$HOME/dotfiles/scripts/shell/list-files-mtime.sh" \
  | fzf --filter "$query" --tiebreak=index | head -15
