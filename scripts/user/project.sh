#!/usr/bin/env bash

PROJECT_ALIAS="$1"

case "$PROJECT_ALIAS" in
  "dotf" | "dotfiles")
    hyperlayout dotfiles
    code ~/dotfiles
    ;;
  "js" | "javascript")
    cd ~/sandbox
    touch index.js
    code ~/sandbox --goto index.js:0
    ;;
  "lt" | "lutr" | "lukastrumm")
    hyperlayout lukastrumm
    code ~/code/lukastrumm
    ;;
  "mezinami")
    hyperlayout mezinami
    code ~/hanaboso/mezi-nami
    ;;
  *)
    echo "Not found"
    ;;
esac
