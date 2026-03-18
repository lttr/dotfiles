#!/usr/bin/env bash

# Sync tracked COSMIC desktop configs between dotfiles and live config.
# Usage:
#   cosmic-sync.sh pull   - copy live config → dotfiles
#   cosmic-sync.sh push   - copy dotfiles → live config

set -euo pipefail

DOTFILES="$HOME/dotfiles/cosmic"
COSMIC="$HOME/.config/cosmic"

# Map: dotfiles_subdir:cosmic_component:key
CONFIGS=(
  "shortcuts:com.system76.CosmicSettings.Shortcuts:custom"
  "shortcuts:com.system76.CosmicSettings.Shortcuts:system_actions"
  "comp:com.system76.CosmicComp:xkb_config"
  "comp:com.system76.CosmicComp:workspaces"
  "comp:com.system76.CosmicComp:input_touchpad"
  "comp:com.system76.CosmicComp:autotile"
  "comp:com.system76.CosmicComp:autotile_behavior"
  "comp:com.system76.CosmicComp:appearance_settings"
  "applist:com.system76.CosmicAppList:favorites"
  "theme:com.system76.CosmicTheme.Mode:is_dark"
)

sync_config() {
  local direction="$1"
  local subdir component key
  local src dst
  local count=0

  for entry in "${CONFIGS[@]}"; do
    IFS=: read -r subdir component key <<< "$entry"
    local dotfile="$DOTFILES/$subdir/$key"
    local livefile="$COSMIC/$component/v1/$key"

    if [[ "$direction" == "pull" ]]; then
      src="$livefile"
      dst="$dotfile"
    else
      src="$dotfile"
      dst="$livefile"
    fi

    if [[ ! -f "$src" ]]; then
      echo "  skip: $component/$key (source not found)"
      continue
    fi

    mkdir -p "$(dirname "$dst")"

    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
      continue
    fi

    cp "$src" "$dst"
    echo "  sync: $subdir/$key"
    ((count++))
  done

  echo "Synced $count file(s)"
}

case "${1:-}" in
  pull)
    echo "Pulling live COSMIC config → dotfiles"
    sync_config pull
    ;;
  push)
    echo "Pushing dotfiles → live COSMIC config"
    sync_config push
    echo "Restart COSMIC to apply changes"
    ;;
  *)
    echo "Usage: cosmic-sync.sh [pull|push]" >&2
    exit 1
    ;;
esac
