#!/usr/bin/env bash
# Name the kitty tab after the first prompt of a session.
# Fires from UserPromptSubmit; runs once per session (marker guards reruns).
# Title format: "<repo>: <two-word title>" (title from a background haiku call).

input=$(cat)
sid=$(jq -r '.session_id // ""' <<< "$input")
[[ -z "$sid" ]] && exit 0

# kitty must be present and we need a window to retitle.
[[ -z "$KITTY_WINDOW_ID" ]] && exit 0
command -v kitten >/dev/null 2>&1 || exit 0

cwd=$(jq -r '.cwd // ""' <<< "$input")
prompt=$(jq -r '.prompt // ""' <<< "$input" | head -c 500)
[[ -z "$prompt" ]] && exit 0

# Only title on the first real prompt of the session.
marker="/tmp/claude-title-$sid.done"
[[ -f "$marker" ]] && exit 0
touch "$marker"

# Repo name from git root, falling back to the cwd basename.
repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "$cwd")")

# Ask haiku for a 2-word name in the background; the agent never waits.
(
  name=$(claude -p --model haiku \
    "Name this coding session in exactly two words based on the request. Reply with only those two words, nothing else: $prompt" \
    | head -1)
  [[ -n "$name" ]] && kitten @ set-tab-title \
    --match "window_id:$KITTY_WINDOW_ID" "$repo: $name"
) &>/dev/null & disown

exit 0
