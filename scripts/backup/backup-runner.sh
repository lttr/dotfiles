#!/usr/bin/env bash

# Prevents the system from beiing shut down while running a backup script

BACKUP_SCRIPT_ID=$1

systemd-inhibit --what="idle:sleep:shutdown:handle-hibernate-key:handle-suspend-key:handle-lid-switch" --who="backup-runner.sh" --why="Running rsync backup" bash /home/lukas/dotfiles/scripts/backup/backup-${BACKUP_SCRIPT_ID}.sh
