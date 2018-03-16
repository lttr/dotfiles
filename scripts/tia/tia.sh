#!/usr/bin/env zsh

IA_DIR=~/Dropbox/ia

handle_selection() {
    if [ -n "$1" ]; then
        if [[ $WSL ]]; then
            WINDOWS_PATH="$(wslpath -s -w "$IA_DIR/$1")"
            if [[ ! $(file --brief --mime-type "$IA_DIR/$1") =~ "text.*"  ]]; then
                cmd.exe /c "start "" "$WINDOWS_PATH""
            else
                gvim.exe "$WINDOWS_PATH" 2>/dev/null
            fi
        else
            $EDITOR "$(realpath "$IA_DIR/$1")"
        fi
    fi
}

# Without parameter: Open file via fzf
# Sort by file access time (newest first)
# With given parameter: Start file search with given query
handle_selection "$( \
    find $IA_DIR ! -path "*/\.*" -type f -printf '%A@|%P\n' \
    | sort -r \
    | awk -F'|' '{OFS="";$1="";print}' \
    | fzf --query "$*" \
    )"
