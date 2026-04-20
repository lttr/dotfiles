#!/usr/bin/env bash

# Start `cl` (claude --dangerously-skip-permissions) with ~/.claude/custom-handoff.md as first prompt.
set -euo pipefail

handoff="${HOME}/.claude/custom-handoff.md"

if [[ ! -s "$handoff" ]]; then
  echo "clh: $handoff missing or empty" >&2
  exit 1
fi

exec claude --dangerously-skip-permissions "$(<"$handoff")" "$@"
