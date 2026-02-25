#!/bin/bash

# Claude Code Format Hook (PostToolUse: Edit|MultiEdit|Write)
# Runs Prettier on changed files when .prettierrc exists
# px = pnpm exec with fallback to pnpm dlx

if [ -f .prettierrc ]; then
  file_path=$(jq -r '.tool_input.file_path')
  case "$file_path" in
    *.js|*.jsx|*.ts|*.tsx|*.vue|*.svelte|*.json|*.css|*.scss|*.less|*.html|*.md|*.yaml|*.yml)
      px prettier --write "$file_path" 2>/dev/null || true
      ;;
  esac
fi
