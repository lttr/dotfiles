#!/bin/bash

# Claude Code Format Hook (PostToolUse: Edit|MultiEdit|Write)
# Runs Prettier on changed files when .prettierrc exists
# vpx = vite-plus package runner (local-first, remote fallback)

if [ -f .prettierrc ]; then
  file_path=$(jq -r '.tool_input.file_path')
  case "$file_path" in
    *.js|*.jsx|*.ts|*.tsx|*.vue|*.svelte|*.json|*.css|*.scss|*.less|*.html|*.md|*.yaml|*.yml)
      vpx prettier --write "$file_path" 2>/dev/null || true
      ;;
  esac
fi
