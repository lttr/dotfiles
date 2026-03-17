#!/usr/bin/env bash

# Sync COSMIC keyboard shortcuts between dotfiles and live config.
# Usage:
#   cosmic-sync-shortcuts.sh pull   - copy live config → dotfiles
#   cosmic-sync-shortcuts.sh push   - copy dotfiles → live config

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles/cosmic/shortcuts"
COSMIC_DIR="$HOME/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1"

case "${1:-}" in
  pull)
    cp "$COSMIC_DIR/custom" "$DOTFILES_DIR/custom"
    cp "$COSMIC_DIR/system_actions" "$DOTFILES_DIR/system_actions"
    echo "Pulled COSMIC shortcuts → dotfiles"
    ;;
  push)
    cp "$DOTFILES_DIR/custom" "$COSMIC_DIR/custom"
    cp "$DOTFILES_DIR/system_actions" "$COSMIC_DIR/system_actions"
    echo "Pushed dotfiles → COSMIC shortcuts (restart COSMIC to apply)"
    ;;
  *)
    echo "Usage: cosmic-sync-shortcuts.sh [pull|push]" >&2
    exit 1
    ;;
esac
