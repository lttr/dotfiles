#!/usr/bin/env bash

# Claude Code Format Hook (PostToolUse: Edit|MultiEdit|Write)
#
# Format the single file just edited by Claude — never the whole project.
#
#   1. Read file_path from tool input JSON on stdin (jq).
#   2. Bail if file no exist or extension not in supported list.
#   3. Walk up tree from file's dir looking for prettier config
#      (.prettierrc*, prettier.config.*). Stop at /, $HOME, or first hit.
#   4. Prettier config found  -> `vpx prettier --write <file>`.
#      No prettier config     -> `cd <file dir> && vp fmt --write <file>`.
#                                cd is needed because vp fmt require cwd inside
#                                a vp workspace; the explicit path scope formatting
#                                to that one file only.
#   5. Errors swallow — vp/prettier may not apply in every project.
#
# vpx = vite-plus package runner (local-first, remote fallback).
# vp fmt = vite-plus unified formatter, run oxfmt under hood.

file_path=$(jq -r '.tool_input.file_path // empty')
[ -z "$file_path" ] && exit 0
[ ! -f "$file_path" ] && exit 0

case "$file_path" in
  *.js|*.jsx|*.mjs|*.cjs|*.ts|*.tsx|*.mts|*.cts|*.vue|*.svelte|*.json|*.jsonc|*.css|*.scss|*.less|*.html|*.md|*.yaml|*.yml) ;;
  *) exit 0 ;;
esac

prettier_configs=(
  .prettierrc
  .prettierrc.json
  .prettierrc.json5
  .prettierrc.yaml
  .prettierrc.yml
  .prettierrc.toml
  .prettierrc.js
  .prettierrc.cjs
  .prettierrc.mjs
  prettier.config.js
  prettier.config.cjs
  prettier.config.mjs
  prettier.config.ts
)

dir=$(dirname "$file_path")
prettier_found=0
while [ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$HOME" ]; do
  for cfg in "${prettier_configs[@]}"; do
    if [ -f "$dir/$cfg" ]; then
      prettier_found=1
      break 2
    fi
  done
  dir=$(dirname "$dir")
done

if [ "$prettier_found" = "1" ]; then
  vpx prettier --write "$file_path" 2>/dev/null || true
else
  (cd "$(dirname "$file_path")" && vp fmt --write "$file_path") 2>/dev/null || true
fi
