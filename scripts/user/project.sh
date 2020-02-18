#!/usr/bin/env bash

PROJECT_ALIAS="$1"

case "$PROJECT_ALIAS" in
  "dotf" | "dotfiles")
    hyperlayout dotfiles
    code ~/dotfiles
    ;;
  "lt" | "lutr" | "lukastrumm")
    hyperlayout lukastrumm
    code ~/code/lukastrumm
    ;;
  "dipo")
    hyperlayout dipo
    code ~/code/contport/web-frontend
    ;;
  *)
    echo "Not found"
    ;;
esac
