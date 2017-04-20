#!/usr/bin/env bash

MY_DIR="$(dirname "$0")"

systemd-inhibit --what="idle:sleep:shutdown:handle-hibernate-key:handle-suspend-key:handle-lid-switch" --who="$0" --why="Running rsync backup" bash /home/lukas/dotfiles/scripts/backup/backup-ztphotos.sh
