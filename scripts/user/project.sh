#!/usr/bin/env bash

PROJECT_ALIAS="$1"

case "$PROJECT_ALIAS" in
  "dotf" | "dotfiles")
    cd ~/dotfiles
    git status
    code ~/dotfiles
    ;;
  "js" | "javascript")
    cd ~/sandbox
    touch index.js
    code ~/sandbox --goto index.js:0
    ;;
  "lt" | "lutr" | "lukastrumm")
    cd ~/code/lukastrumm
    npm run serve
    code ~/code/lukastrumm
    ;;
  *)
    echo "Not found"
    ;;
esac
