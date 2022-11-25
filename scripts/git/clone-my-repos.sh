#!/usr/bin/env zsh

USER='lttr'
CODE_DIR="$HOME/code"

REPOS=$(gh api users/${USER}/repos --paginate --jq '.[] | select(.archived != true) | select(.fork != true) | .ssh_url')

cd $CODE_DIR

for URL in $REPOS; do
  git clone $URL
done

