#!/usr/bin/env zsh

GH_USER='lttr'
CODE_DIR="$HOME/code"

# REPOS=$(gh api users/${GH_USER}/repos --paginate --jq '.[] | select(.archived != true) | select(.fork != true) | .ssh_url')
REPOS=$(gh repo list --json "name,isFork,isArchived" --jq  '.[] | select(.isArchived != true) | select(.isFork != true) | .name')

cd $CODE_DIR

echo $REPOS | while read NAME ; do
  if [ "$NAME" != "dotfiles" ]; then
    gh repo clone "$NAME"
  fi
done

