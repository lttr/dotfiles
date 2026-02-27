#!/usr/bin/env zsh

# Dependencies:
# - git recursive-status

recursive_status=~/dotfiles/scripts/git/git-recursive-status.sh

. $recursive_status  ~/dotfiles 1 true
. $recursive_status  ~/code 2 true
. $recursive_status  ~/work 3 true
