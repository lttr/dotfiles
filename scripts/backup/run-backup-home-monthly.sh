#!/usr/bin/env bash

MY_ARGUMENT=monthly

MY_DIR="$(dirname "$0")"

systemd-inhibit --what="idle:sleep:shutdown:handle-hibernate-key:handle-suspend-key:handle-lid-switch" --who="$0" --why="Running rsync backup" bash ~/dotfiles/scripts/backup/backup-home.sh $MY_ARGUMENT