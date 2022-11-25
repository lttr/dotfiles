#!/usr/bin/env zsh

GH_USER='lttr'
CODE_DIR="$HOME/code"

REPOS=$(gh api users/${GH_USER}/repos --paginate --jq '.[] | select(.archived != true) | select(.fork != true) | .ssh_url')

cd $CODE_DIR

for URL in $REPOS; do
  git clone "$URL"
done

