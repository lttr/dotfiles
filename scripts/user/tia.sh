#!/usr/bin/env bash

IA_DIR=~/Dropbox/ia

handle_selection() {
    $EDITOR "$IA_DIR/$1"
}

if [[ -z "$@" ]]
then
    handle_selection "$( \
        find $IA_DIR ! -path "*/\.*" -type f -printf '%A@ %P\n' \
        | sort -r \
        | awk '{OFS="";$1="";print}' \
        | fzf \
        )"
else
    ag --smart-case --color-match "30;47" "$@" $IA_DIR
fi

