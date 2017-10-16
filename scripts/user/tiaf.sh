#!/usr/bin/env bash

IA_DIR=~/Dropbox/ia

file-search() {
    local out tokens file line
    out=$(ag --follow --nobreak --noheading --nocolor "\w" $IA_DIR | fzf --query "$*")
    IFS=':' tokens=( $out )
    file=${tokens[1]}
    line=${tokens[2]}
    if [ -n "$out" ]; then
        vim "$file" +${line} +"setlocal cursorline" < /dev/tty
    fi
}

file-search "$1"
