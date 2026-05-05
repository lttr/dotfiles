#!/usr/bin/env bash

# Claude Code Format Hook (PostToolUse: Edit|MultiEdit|Write)
#
# Format the single file just edited by Claude — never the whole project.
#
#   1. Read file_path from tool input JSON on stdin (jq).
#   2. Bail if file no exist or extension not in supported list.
#   3. Walk up tree from file's dir. At each dir check for:
#        - prettier config (.prettierrc*, prettier.config.*)
#        - oxfmt trigger (vite.config.*, .oxfmtrc*, oxfmt.config.*)
#      First dir with a hit wins. Prettier wins ties at same dir.
#      Stop at /, $HOME, or first hit.
#   4. Prettier hit -> `vpx prettier --write <file>`.
#      Oxfmt hit    -> `cd <file dir> && vp fmt --write <file>`.
#                      cd needed because vp fmt require cwd inside a vp
#                      workspace; explicit path scope formatting to that file.
#      No hit       -> exit 0 (no implicit formatting).
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

oxfmt_configs=(
  vite.config.ts
  vite.config.js
  vite.config.mjs
  vite.config.cjs
  vite.config.mts
  vite.config.cts
  .oxfmtrc
  .oxfmtrc.json
  oxfmt.config.js
  oxfmt.config.cjs
  oxfmt.config.mjs
  oxfmt.config.ts
  oxfmt.config.json
)

dir=$(dirname "$file_path")
formatter=""
while [ -n "$dir" ] && [ "$dir" != "/" ] && [ "$dir" != "$HOME" ]; do
  for cfg in "${prettier_configs[@]}"; do
    if [ -f "$dir/$cfg" ]; then
      formatter="prettier"
      break 2
    fi
  done
  for cfg in "${oxfmt_configs[@]}"; do
    if [ -f "$dir/$cfg" ]; then
      formatter="oxfmt"
      break 2
    fi
  done
  dir=$(dirname "$dir")
done

case "$formatter" in
  prettier) vpx prettier --write "$file_path" 2>/dev/null || true ;;
  oxfmt)    (cd "$(dirname "$file_path")" && vp fmt --write "$file_path") 2>/dev/null || true ;;
  *)        exit 0 ;;
esac
