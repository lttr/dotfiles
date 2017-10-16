#!/usr/bin/env bash

IA_DIR=~/Dropbox/ia

handle_selection() {
    if [ -n "$1" ]; then
        $EDITOR "$IA_DIR/$1"
    fi
}

# Without parameter: Open file via fzf
# Sort by file access time (newest first)
# With given parameter: Start file search with given query
handle_selection "$( \
    find $IA_DIR ! -path "*/\.*" -type f -printf '%A@ %P\n' \
    | sort -r \
    | awk '{OFS="";$1="";print}' \
    | fzf --query "$*" \
    )"
