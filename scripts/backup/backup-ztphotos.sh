#!/bin/bash

SOURCE="/media/lukas/Seagate Expansion Drive/Fotky"

TODAY=$(date "+%Y-%m-%d")
BACKUP_NAME=${TODAY}-ztphotos
BACKUP_DISK_MOUNTPOINT=/media/backup_hdd_320

TARGET=${BACKUP_DISK_MOUNTPOINT}/backups/${BACKUP_NAME}/

LOG_FILE=/home/lukas/.cache/rsync-backup-${BACKUP_NAME}.log

mkdir -p $TARGET

# rsync:
# a = archive
# L = copy targets of symlinks
# h = human readable
# modify-window = ignore small differences between file modification times
# progress2 = statistics for the whole transfer

rsync -aLh --info=progress2 --modify-window=5 --delete --log-file=$LOG_FILE $SOURCE $TARGET
