#!/usr/bin/env bash

BACKUP_NAME=ztphotos

BACKUP_FREQUENCY=monthly

BACKUP_DISK_MOUNTPOINT=backup_hdd_320

DIRS=(
/media/spolecne_uloziste/Fotky
)

TARGET=/media/${BACKUP_DISK_MOUNTPOINT}/backups/${BACKUP_NAME}-${BACKUP_FREQUENCY}/

LOG_FILE=/home/lukas/.cache/rsync-backup-${BACKUP_NAME}-${BACKUP_FREQUENCY}.log


mkdir -p $TARGET

# rsync:
# a = archive
# L = copy targets of symlinks
# h = human readable
# modify-window = ignore small differences between file modification times
# progress2 = statistics for the whole transfer

rsync -aLh --info=progress2 --modify-window=5 --delete --log-file=$LOG_FILE ${DIRS[@]} $TARGET
