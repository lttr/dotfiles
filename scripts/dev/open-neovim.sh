#!/bin/sh

# Adapted from https://github.com/romhml/nvux/blob/main/nvux

show_help() {
    cat << EOF
open-neovim - Open files in existing neovim instance within kitty

USAGE:
    open-neovim [OPTIONS] [FILE] [+LINE]

OPTIONS:
    -h, --help        Show this help message and exit

ARGUMENTS:
    FILE              Path to file to open (optional)
    LINE              Line number to jump to after opening file (optional)

DESCRIPTION:
    open-neovim opens files in an existing Neovim instance running
    within a kitty terminal. It searches for active Neovim processes in
    kitty tabs and opens the specified file in that instance.
    
    If no existing Neovim instance is found, open-neovim will create one in a new tab.
    When not running within kitty, open-neovim falls back to launching
    regular Neovim.

EXAMPLES:
    open-neovim                          # Open nvim in existing kitty tab
    open-neovim file.txt                 # Open file.txt
    open-neovim file.txt 25              # Open file.txt and jump to line 25
    open-neovim /path/to/script.sh 1     # Open script.sh and jump to first line
EOF
}

# Parse options
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo "Use -h for help" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

FILE="$1"
LINE="$2"

# Fallback to regular nvim if not in kitty
if [ "$TERM" != "xterm-kitty" ]; then
    exec nvim "$@"
    exit
fi

# Find kitty's communication socket
KITTY_SOCKET=${KITTY_LISTEN_ON:-$(ls /tmp/kitty-* 2>/dev/null | head -1)}

# Find tabs running nvim
NVIM_TAB=$(kitty @ --to $KITTY_SOCKET ls | jq -r '.[] | select(.is_focused) | .tabs[] | select(.windows[].foreground_processes[].cmdline[]? | contains("nvim")) | .id' | head -1)

if [ -n "$NVIM_TAB" ]; then
    # Focus the tab with nvim
    kitty @ --to $KITTY_SOCKET focus-tab --match "id:$NVIM_TAB"

    # Sends an escape in case the user is in insert mode.
    kitty @ --to $KITTY_SOCKET send-text --match "id:$NVIM_TAB" $'\x1b'

    # Open file in existing nvim
    if [ -n "$LINE" ]; then
        kitty @ --to $KITTY_SOCKET send-text --match "id:$NVIM_TAB" ":e $FILE | $LINE"'\r'
    elif [ -n "$FILE" ]; then
        kitty @ --to $KITTY_SOCKET send-text --match "id:$NVIM_TAB" ":e $FILE"'\r'
    fi
else
    # Create new tab with nvim
    if [ -n "$LINE" ]; then
        kitty @ --to $KITTY_SOCKET launch --type=tab --cwd "$(pwd)" nvim "$FILE" +"$LINE"
    else
        kitty @ --to $KITTY_SOCKET launch --type=tab --cwd "$(pwd)" nvim "$FILE"
    fi
fi
