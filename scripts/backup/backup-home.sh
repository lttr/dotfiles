#!/usr/bin/env bash

LOG_FILE=~/.cache/rsync-backup-home.log
TARGET=/media/hdd/backups/home-weekly/
DIRS=(
~/down 
~/Dropbox 
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
rsync -ah --progress --modify-window=5 --delete --log-file=$LOG_FILE ${DIRS[@]} $TARGET
