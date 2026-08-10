#!/usr/bin/env bash
# Name the kitty tab after the first prompt of a session.
# Fires from UserPromptSubmit; runs once per session (marker guards reruns).
# Title format: "<repo>: <two-word title>" (title from a background haiku call).

# The naming call below is itself a `claude -p` run, which fires UserPromptSubmit
# again in the child. Without this guard each run spawns another run: a fork bomb.
[[ -n "$CLAUDE_SESSION_TITLE_HOOK" ]] && exit 0

input=$(cat)
sid=$(jq -r '.session_id // ""' <<< "$input")
[[ -z "$sid" ]] && exit 0

# kitty must be present and we need a window to retitle.
# kitten is not always on PATH (kitty.app installs outside it), so resolve it.
[[ -z "$KITTY_WINDOW_ID" ]] && exit 0
kitten=$(command -v kitten || echo "$HOME/.local/kitty.app/bin/kitten")
[[ -x "$kitten" ]] || exit 0

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
  reply=$(CLAUDE_SESSION_TITLE_HOOK=1 timeout 60 claude -p --model haiku \
    "Name this coding session in exactly two words based on the request. Reply with only those two words, nothing else: $prompt" \
    </dev/null 2>/dev/null | head -1 | tr -s '[:space:]' ' ' \
    | tr '[:upper:]' '[:lower:]' | sed 's/^ *//; s/ *$//')

  # Haiku occasionally answers with a sentence instead of a name.
  # Accept only one or two plain words; anything else leaves the title alone.
  [[ "$reply" =~ ^[A-Za-z0-9][A-Za-z0-9+.-]*([[:space:]][A-Za-z0-9][A-Za-z0-9+.-]*)?$ ]] || exit 0

  "$kitten" @ set-tab-title \
    --match "window_id:$KITTY_WINDOW_ID" "$repo: $reply"
) &>/dev/null & disown

exit 0
