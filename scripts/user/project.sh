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
  "jira")
    ( firefox http://localhost:8080 &>/dev/null & )
    echo 'launch make dev 
    launch make reload' | kitty --detach --start-as=maximized --directory '~/hanaboso/jira-to-timesheeter' --session=-
    cd ~/hanaboso/jira-to-timesheeter && nvim -c "lua require('user.telescope').project_files()"
    ;;
  *)
    echo "Not found"
    ;;
esac
