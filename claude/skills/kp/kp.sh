#!/usr/bin/env bash
# Open a kitty split and paste the command from stdin at the shell prompt, without running it.
# Usage: kp.sh [cwd] <<'CMD' ... CMD
set -euo pipefail

cwd="${1:-$PWD}"
cmd="$(cat)" # $(...) strips trailing newlines, so nothing gets executed

if ! kitty @ ls >/dev/null 2>&1; then
  printf '%s' "$cmd" | wl-copy
  echo "kitty remote control unavailable; copied to clipboard"
  exit 0
fi

id="$(kitty @ launch --type window --cwd "$cwd")"

# Wait for the shell to draw its prompt before pasting
for _ in $(seq 50); do
  [[ -n "$(kitty @ get-text --match "id:$id" | tr -d '[:space:]')" ]] && break
  sleep 0.1
done

printf '%s' "$cmd" | kitty @ send-text --match "id:$id" --bracketed-paste=enable --stdin
echo "pasted into kitty window $id"
