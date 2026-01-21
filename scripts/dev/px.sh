#!/usr/bin/env bash
# pnpm exec with fallback to dlx
#
# Tries local/workspace binaries first (pnpm exec), falls back to
# downloading and running (pnpm dlx) only if the command isn't installed.
# Preserves errors from commands that exist but fail.

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Capture stderr to detect "not found" vs other failures
pnpm exec "$@" 2>"$tmp"
code=$?

if [[ $code -eq 0 ]]; then
  exit 0
elif grep -q 'not found' "$tmp"; then
  # Command not installed locally - download and run
  pnpm dlx "$@"
else
  # Command exists but failed - show error
  cat "$tmp" >&2
  exit $code
fi
