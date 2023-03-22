#!/usr/bin/env bash

IA_DIR=~/ia

file-search() {
    local out tokens file line
    out=$(rg --follow --line-number "\w" $IA_DIR | fzf --query "$*")
    IFS=':' tokens=( $out )
    file=${tokens[0]}
    line=${tokens[1]}
    if [ -n "$out" ]; then
        $EDITOR "$file" +${line} +"setlocal cursorline" < /dev/tty
    fi
}

file-search "$1"
