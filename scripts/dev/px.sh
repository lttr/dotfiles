#!/usr/bin/env bash
# pnpm exec with fallback to dlx
#
# Tries local/workspace binaries first (pnpm exec), falls back to
# downloading and running (pnpm dlx) only if the command isn't installed.
# Preserves errors from commands that exist but fail.

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Capture all output to detect "not found" vs other failures
pnpm exec "$@" >"$tmp" 2>&1
code=$?

if [[ $code -eq 0 ]]; then
  cat "$tmp"
  exit 0
elif grep -qE 'not found|ERR_PNPM_RECURSIVE_EXEC_NO_PACKAGE' "$tmp"; then
  # Command not installed locally - download and run
  pnpm dlx "$@"
else
  # Command exists but failed - show output
  cat "$tmp" >&2
  exit $code
fi
