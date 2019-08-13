#!/usr/bin/env bash

name=$1

if [ -z $name ]; then
  echo 'Missing sandbox name'
else
  cd ~/sandbox

  command -v pollinate >/dev/null 2>&1 || { echo >&2 "I require 'pollinate' but it's not installed. Aborting."; exit 1; }

  pollinate ~/code/web-start --name $name

  cd $name

  git init
  git add .
  git commit -m "Initial commit"

  code .
  code --reuse-window index.html style.css script.js

  browser-sync start --server --files . --no-notify --open .
fi