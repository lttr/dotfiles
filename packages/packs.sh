#!/usr/bin/env bash

help() {
    echo "Usage: packs <type> history"
    echo "<type> can by one of: ubuntu, node, python, vim, zsh, submodule, custom"
    echo ""
    echo "Commands:"


    echo "history     List history of installations"
    echo "installed   List installed packages"
    echo "configured  List packages that should be installed according to configuration"
    echo "missing     List missing packages according to configuration"
    echo "extra       List extra packages according to configuration"
    echo "install     Install packages which are not yet installed and list them"
    echo "updatable   List packages that are installed but can be updated"
    echo "update      Update packages and list which got update"
    echo "process     Install everything missing and update every package"
}

# ===== Constants =====
DOTFILES_DIR="$HOME/dotfiles"
PACKAGE_LISTS_DIR="$DOTFILES_DIR/packages"

# ===== Ubuntu =====
UBUNTU_PACKS_PATH="$PACKAGE_LISTS_DIR/ubuntu.txt"
ubuntu-history() {
    zgrep -hE '^(Start-Date:|Commandline:)' \
        $(ls -tr /var/log/apt/history.log*.gz ) \
        | egrep -v 'aptdaemon|upgrade' | egrep -B1 '^Commandline:'
}
ubuntu-installed() {
    comm -23 \
        <( apt-mark showmanual | sort -u ) \
        <( gzip -dc /var/log/installer/initial-status.gz \
            | sed -n 's/^Package: //p' | sort -u )
}
ubuntu-missing() {
    comm -13 <( ubuntu-installed ) <( cat "$UBUNTU_PACKS_PATH" | sort -u )
}
ubuntu-extra() {
    comm -23 <( ubuntu-installed ) <( cat "$UBUNTU_PACKS_PATH" | sort -u )
}

# ===== Node =====
NODE_PACKS_PATH="$PACKAGE_LISTS_DIR/node.txt"
yarn-installed() {
    yarn global ls --json 2>/dev/null \
        | jq -cr 'select(.type | test("info")) | .data | split("\"")| .[1]'
}
yarn-installed-no-versions() {
    yarn-installed | sed 's/\(.*\)@.*/\1/' | sort -u
}
yarn-missing() {
    comm -13 <( yarn-installed-no-versions ) <( cat "$NODE_PACKS_PATH" | sort -u )
}
yarn-extra() {
    comm -23 <( yarn-installed-no-versions ) <( cat "$NODE_PACKS_PATH" | sort -u )
}

# ===== Python =====
PYTHON_PACKS_PATH="$PACKAGE_LISTS_DIR/python.txt"
python-installed() {
    pip list --format=columns
}
python-installed-no-versions() {
    pip list --format=legacy | awk '{print $1}' | sort
}
python-missing() {
    comm -13 <( python-installed-no-versions ) <( cat "$PYTHON_PACKS_PATH" | sort -u )
}
python-extra() {
    comm -23 <( python-installed-no-versions ) <( cat "$PYTHON_PACKS_PATH" | sort -u )
}

# ===== Vim =====
VIMRC_PATH="$HOME/.vimrc"
VIM_PLUGINS_PATH="$HOME/.vim/plugged"
vim-configured() {
    cat $VIMRC_PATH | grep '^Plug' | sed "s/^Plug '\([^']\+\)'.*/\1/" \
        | cut -d'/' -f2 | sort
}

# ===== Zsh =====
ZSH_PACKS_PATH="$PACKAGE_LISTS_DIR/zsh.txt"
zsh-installed() {
    antibody list | awk -F'-SLASH-' '{print $4"/"$5}' | sort
}
zsh-missing() {
    comm -13 <( zsh-installed ) <( cat "$ZSH_PACKS_PATH" | sort -u )
}
zsh-extra() {
    comm -23 <( zsh-installed ) <( cat "$ZSH_PACKS_PATH" | sort -u )
}

# ===== Arguments =====
if [ $# -lt 2 ]; then
    help
    exit 
fi

TYPE=$1
COMMAND=$2
ADDITIONAL_ARGUMENT=$3

# ===== Execution =====
case $TYPE in
    ubuntu)
        case $COMMAND in
            history)
                ubuntu-history
            ;;
            installed)
                ubuntu-installed
            ;;
            configured)
                cat "$UBUNTU_PACKS_PATH"
            ;;
            missing)
                ubuntu-missing
            ;;
            extra)
                ubuntu-extra
            ;;
            install)
                sudo apt-get update
                sudo apt-get install -y $( ubuntu-missing )
            ;;
            updatable)
                sudo apt-get update
                echo
                sudo apt list --upgradable $ADDITIONAL_ARGUMENT
            ;;
            update)
                sudo apt-get update
                echo
                sudo apt-get dist-upgrade $ADDITIONAL_ARGUMENT
            ;;
            process)
                sudo apt-get update
                echo
                sudo apt-get install -y $( ubuntu-missing )
                echo
                sudo apt-get dist-upgrade -y
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    node)
        case $COMMAND in
            history)
                echo "Unsupported command"
            ;;
            installed)
                yarn-installed
            ;;
            configured)
                cat "$NODE_PACKS_PATH"
            ;;
            missing)
                yarn-missing
            ;;
            extra)
                yarn-extra
            ;;
            install)
                yarn global add $( cat "$NODE_PACKS_PATH" )
            ;;
            updatable)
                yarn global upgrade-interactive
            ;;
            update)
                yarn global upgrade
            ;;
            process)
                yarn global install $( cat "$NODE_PACKS_PATH" )
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    python)
        case $COMMAND in
            history)
                echo "Unsupported command"
            ;;
            installed)
                python-installed
            ;;
            configured)
                cat $PYTHON_PACKS_PATH
            ;;
            missing)
                python-missing
            ;;
            extra)
                python-extra
            ;;
            install)
                pip install -r "$PYTHON_PACKS_PATH"
            ;;
            updatable)
            ;;
            update)
                pip install -r "$PYTHON_PACKS_PATH" --upgrade
            ;;
            process)
                pip install -r "$PYTHON_PACKS_PATH"
                pip install -r "$PYTHON_PACKS_PATH" --upgrade
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    vim)
        case $COMMAND in
            history)
                echo "Unsupported command"
            ;;
            installed)
                ls -1 "$VIM_PLUGINS_PATH"
            ;;
            configured)
                vim-configured
            ;;
            missing)
                echo "Unsupported command"
            ;;
            extra)
                echo "Unsupported command"
            ;;
            install)
                vim +PlugInstall +qall
            ;;
            updatable)
                echo "Unsupported command"
            ;;
            update)
                vim +PlugUpdate +qall
            ;;
            process)
                vim +PlugClean +PlugInstall +PlugUpdate +qall
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    zsh)
        case $COMMAND in
            history)
                echo "Unsupported command"
            ;;
            installed)
                zsh-installed
            ;;
            configured)
                cat "$ZSH_PACKS_PATH"
            ;;
            missing)
                zsh-missing
            ;;
            extra)
                zsh-extra
            ;;
            install)
                antibody bundle < "$ZSH_PACKS_PATH"
            ;;
            updatable)
                echo "Unsupported command"
            ;;
            update)
                antibody update
            ;;
            process)
                antibody bundle < "$ZSH_PACKS_PATH"
                antibody update
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    submodule)
        case $COMMAND in
            history)
                echo "Unsupported command"
            ;;
            installed)
                cd $DOTFILES_DIR
                git submodule
            ;;
            configured)
                cat $DOTFILES_DIR/.gitmodules
            ;;
            missing)
                echo "Unsupported command"
            ;;
            extra)
                echo "Unsupported command"
            ;;
            install)
                cd $DOTFILES_DIR
                git submodule update --init --recursive
            ;;
            updatable)
                echo "Unsupported command"
            ;;
            update)
                cd $DOTFILES_DIR
                git submodule update --init --recursive
            ;;
            process)
                cd $DOTFILES_DIR
                git submodule update --init --recursive
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    custom)
        case $COMMAND in
            history)
                echo "Unsupported command"
            ;;
            installed)
                echo "Unsupported command"
            ;;
            configured)
                cat "$PACKAGE_LISTS_DIR"/custom.sh | sed -n 's/#Program \(.*\)/\1/p'
            ;;
            missing)
                echo "Unsupported command"
            ;;
            extra)
                echo "Unsupported command"
            ;;
            install)
                "$PACKAGE_LISTS_DIR"/custom.sh
            ;;
            updatable)
                echo "Unsupported command"
            ;;
            update)
                echo "Unsupported command"
            ;;
            process)
                echo "Unsupported command"
            ;;
            *)
                echo "Unsupported command"
            ;;
        esac
    ;;
    *)
        echo "Unsupported type"
    ;;
esac

