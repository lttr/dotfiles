#!/bin/bash

ECHO='echo '
for branch in $(git branch -a | sed 's/^\s*//' | sed 's/^remotes\///' | grep -v 'master$'); do
  if [[ "$(git log $branch --since "2 months ago" | wc -l)" -eq 0 ]]; then
    if [ "$1" = "-doit" ]; then
      ECHO=""
    fi
    local_branch_name=$(echo "$branch" | sed 's/remotes\/origin\///')
    $ECHO git branch -D $local_branch_name
    $ECHO git push origin --delete $local_branch_name
  fi
done