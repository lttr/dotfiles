#!/usr/bin/env bash

# Run-or-raise for COSMIC desktop panel favorites.
# Reads app list from COSMIC panel favorites config, resolves each to its
# app_id (StartupWMClass) and launch command from .desktop files.
# Usage: cosmic-panel-activate.sh <slot-number>  (1-indexed)
#
# Prerequisites:
#   - cosmic-ext-window-helper (https://github.com/lapause/cosmic-ext-window-helper)
#   - COSMIC desktop with panel favorites configured
#   - Each favorite app needs a .desktop file with StartupWMClass matching its Wayland app_id
#   - Bind Super+1..9 to this script in COSMIC Settings > Keyboard Shortcuts

set -euo pipefail

SLOT="${1:-}"
FAVORITES_FILE="$HOME/.config/cosmic/com.system76.CosmicAppList/v1/favorites"
DESKTOP_DIRS=(
  "$HOME/.local/share/flatpak/exports/share/applications"
  "$HOME/.local/share/applications"
  "/usr/share/applications"
  "/var/lib/flatpak/exports/share/applications"
)

if [[ -z "$SLOT" || ! "$SLOT" =~ ^[0-9]+$ ]]; then
  echo "Usage: cosmic-panel-activate.sh <slot-number>" >&2
  exit 1
fi

if [[ ! -f "$FAVORITES_FILE" ]]; then
  echo "Favorites file not found: $FAVORITES_FILE" >&2
  exit 1
fi

# Parse the Ron-format favorites list into a bash array
# Format: ["app1", "app2", ...]
mapfile -t FAVORITES < <(
  sed -n 's/^[[:space:]]*"\(.*\)".*/\1/p' "$FAVORITES_FILE"
)

INDEX=$((SLOT - 1))
if [[ $INDEX -lt 0 || $INDEX -ge ${#FAVORITES[@]} ]]; then
  echo "Slot $SLOT out of range (1-${#FAVORITES[@]})" >&2
  exit 1
fi

FAV_NAME="${FAVORITES[$INDEX]}"

# Find .desktop file for this favorite
find_desktop_file() {
  local name="$1"
  # Try exact match (e.g. "firefox.desktop", "Ferdium.desktop")
  for dir in "${DESKTOP_DIRS[@]}"; do
    for candidate in "${name}.desktop" "${name,,}.desktop"; do
      if [[ -f "$dir/$candidate" ]]; then
        echo "$dir/$candidate"
        return
      fi
    done
  done
  # For Edge PWAs (msedge-{appid}-{profile}), search by the app hash
  if [[ "$name" =~ ^msedge-_?([a-z]+)- ]]; then
    local app_hash="${BASH_REMATCH[1]}"
    for dir in "${DESKTOP_DIRS[@]}"; do
      [[ -d "$dir" ]] || continue
      local match
      match=$(ls "$dir"/msedge-"${app_hash}"*.desktop 2>/dev/null | head -1)
      if [[ -n "$match" ]]; then
        echo "$match"
        return
      fi
    done
  fi
  # Try flatpak reverse-DNS naming: convert "microsoft-edge" to regex "microsoft.*edge"
  # to match "com.microsoft.Edge.desktop"
  local pattern
  pattern=$(echo "$name" | sed 's/-/.*/g')
  for dir in "${DESKTOP_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    local match
    match=$(ls "$dir"/*.desktop 2>/dev/null | grep -i "$pattern" | grep -v 'msedge-' | head -1)
    if [[ -n "$match" ]]; then
      echo "$match"
      return
    fi
  done
}

DESKTOP_FILE=$(find_desktop_file "$FAV_NAME")

if [[ -z "$DESKTOP_FILE" ]]; then
  echo "No .desktop file found for: $FAV_NAME" >&2
  exit 1
fi

# Extract StartupWMClass (= Wayland app_id) and Exec command
APP_ID=$(sed -n 's/^StartupWMClass=//p' "$DESKTOP_FILE" | head -1)
EXEC_CMD=$(sed -n 's/^Exec=//p' "$DESKTOP_FILE" | head -1)

# Strip desktop file field codes and flatpak file-forwarding wrappers from Exec
EXEC_CMD=$(echo "$EXEC_CMD" | sed 's/ --file-forwarding//g; s/@@u //g; s/ @@//g; s/@@//g; s/ %[uUfFdDnNickvm]//g')

# Fallback: use favorite name as app_id if no StartupWMClass
APP_ID="${APP_ID:-$FAV_NAME}"

if [[ -z "$EXEC_CMD" ]]; then
  echo "No Exec= found in $DESKTOP_FILE" >&2
  exit 1
fi

QUERY="app_id = '${APP_ID}'"

# Activate existing window, or launch if none found (exit code 10)
if ! cosmic-ext-window-helper activate "$QUERY" 2>/dev/null; then
  nohup $EXEC_CMD &>/dev/null &
  disown
fi
