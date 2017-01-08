#!/usr/bin/env bash

BACKUP_NAME=home

BACKUP_FREQUENCY=$1

BACKUP_DISK_MOUNTPOINT=backup_hdd_500

DIRS=(
~/Dropbox
~/dotfiles
~/code
~/fotky
~/grafika
~/hry
~/hudba
~/informace
~/moje
~/pc
~/skaut
~/tasks
~/web
)

TARGET=/media/${BACKUP_DISK_MOUNTPOINT}/backups/${BACKUP_NAME}-${BACKUP_FREQUENCY}/

LOG_FILE=~/.cache/rsync-backup-${BACKUP_NAME}-${BACKUP_FREQUENCY}.log


mkdir -p $TARGET

# rsync:
# a = archive
# L = copy targets of symlinks
# h = human readable
# modify-window = ignore small differences between file modification times
# progress2 = statistics for the whole transfer

rsync -aLh --info=progress2 --modify-window=5 --delete --log-file=$LOG_FILE ${DIRS[@]} $TARGET
