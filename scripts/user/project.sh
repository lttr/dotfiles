#!/usr/bin/env bash

PROJECT_ALIAS="$1"

case "$PROJECT_ALIAS" in
  "dotf" | "dotfiles")
    code ~/dotfiles
    cd ~/dotfiles
    git status
    ;;
  "js" | "javascript")
    cd ~/sandbox
    touch index.js
    code ~/sandbox --goto index.js:0
    ;;
  "lt" | "lutr" | "lukastrumm")
    code ~/code/lukastrumm
    cd ~/code/lukastrumm
    npm run serve
    ;;
  *)
    echo "Not found"
    ;;
esac
