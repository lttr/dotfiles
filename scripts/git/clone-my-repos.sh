#!/usr/bin/env zsh

USER='lttr'
CODE_DIR="$HOME/code"

REPOS=$(gh api users/lttr/repos --paginate --jq '.[] | select(.archived != true) | select(.fork != true) | .ssh_url')

cd $CODE_DIR

for URL in $REPOS; do
  git clone $URL
end

