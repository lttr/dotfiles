#!/usr/bin/env bash
# Run-or-raise Google Calendar in a chromeless Chrome app window.
set -uo pipefail

URL="https://calendar.google.com/calendar/u/0/r"
QUERY="app_id ~= 'calendar.google.com'"

if cosmic-ext-window-helper list "$QUERY" 2>/dev/null | grep -q '"id"'; then
  exec cosmic-ext-window-helper activate "$QUERY"
fi

exec google-chrome-stable \
  --profile-directory=Default \
  --app="$URL" \
  --window-size=1200,840 >/dev/null 2>&1
