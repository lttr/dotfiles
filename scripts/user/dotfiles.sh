#!/usr/bin/env bash

# Small utility for managing dofiles
# * changes current directory to dotfiles dir
# * lists install scripts
# * executes install scripts

# Depends on: [dotbot](https://github.com/anishathalye/dotbot)

set -e

# Constants
DOTFILES="$HOME/dotfiles"
CONFIG_SUFFIX=".conf.yaml"
INSTALL_DIR="${DOTFILES}/install"
CONFIG_DIR="${DOTFILES}/install/config"

# Functions
help() {
    echo "Usage: dotfiles [action] [type] [file]"
    echo "Actions:"
    echo "    help               => shows this help"
    echo "    list script        => list available install scripts"
    echo "    list config        => list available config files"
    echo "    list script [file] => cat given script file"
    echo "    list config [file] => cat given config file"
    echo "    edit script [file] => edit given script file"
    echo "    edit config [file] => edit given config file"
    echo "    install [file]     => run given script file"
    echo "    install all        => run all scripts (install whole machine)"
}

ACTION="$1"
TYPE="$2"
FILE="$3"


case "$ACTION" in
    help | h | "")
        help
        ;;
    list | l)
        case "$TYPE" in
            script | s)
                case "$FILE" in
                    "")
                        find "${INSTALL_DIR}" -maxdepth 1 -type f -printf '%f\n' | sort
                        ;;
                    *)
                        find "${INSTALL_DIR}" -maxdepth 1 -name "*${FILE}*" -exec cat "{}" \;
                esac
                ;;
            config | c)
                case "$FILE" in
                    "")
                        find "${CONFIG_DIR}" -maxdepth 1 -type f -printf '%f\n' | sort
                        ;;
                    *)
                        find "${CONFIG_DIR}" -maxdepth 1 -name "*${FILE}*" -exec cat "{}" \;
                esac
                ;;
            *)
                echo "Please specify type {script|s|config|c}"
                ;;
        esac
        ;;
    edit | e)
        case "$TYPE" in
            script | s)
                find "${INSTALL_DIR}" -maxdepth 1 -name "*${FILE}*" -exec $EDITOR "{}" \;
                ;;
            config | c)
                find "${CONFIG_DIR}" -maxdepth 1 -name "*${FILE}*" -exec $EDITOR "{}" \;
                ;;
            *)
                echo "Please specify type {script|s|config|c}"
                ;;
        esac
        ;;
    install | i)
        # $TYPE has the role of $FILE here
        [ -n "$FILE" ] && echo "Just one argument for action install is needed." && exit 1
        case "$TYPE" in
            all)
                for SCRIPT in ${INSTALL_DIR}/?_*
                do
                    if [ -f $SCRIPT -a -x $SCRIPT ]; then
                        $SCRIPT
                    fi
                done
                ;;
            wsl)
                for SCRIPT in ${INSTALL_DIR}/?_*
                do
                    if [ -f $SCRIPT -a -x $SCRIPT ]; then
                        $SCRIPT
                    fi
                done
                ;;
            test)
                for SCRIPT in ${INSTALL_DIR}/*
                do
                    if [ -f $SCRIPT -a -x $SCRIPT ]; then
                        echo $SCRIPT
                    fi
                done
                ;;
            "")
                find "${INSTALL_DIR}" -maxdepth 1 -type f -printf '%f\n' | sort
                ;;
            *)
                find "${INSTALL_DIR}" -maxdepth 1 -name "*${TYPE}*" -exec "{}" \;
                ;;
        esac
        ;;
    *)
        help
        ;;
esac

