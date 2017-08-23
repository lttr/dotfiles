#             _
#            | |
#   ____ ___ | |__    ___  _ __ __   __
#  |_  // __|| '_ \  / _ \| '_ \\ \ / /
#   / / \__ \| | | ||  __/| | | |\ V /
#  /___||___/|_| |_| \___||_| |_| \_/
#


if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
fi
if [ -d "$HOME/.local/bin" ] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

YARN_GLOBAL=~/.yarn-global
if [ -d "$YARN_GLOBAL" ] ; then
    export PATH="$YARN_GLOBAL:$PATH"
fi

export PAGER=/usr/bin/less
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim
export BROWSER=/usr/bin/google-chrome
export TERMINAL=/usr/bin/urxvt
export TERM=rxvt-unicode-256color

export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
export LC_CTYPE=en_GB.UTF-8
export LC_NUMERIC=cs_CZ.UTF-8
export LC_TIME=en_GB.UTF-8
export LC_COLLATE=en_GB.UTF-8
export LC_MONETARY=cs_CZ.UTF-8
export LC_MESSAGES=en_GB.UTF-8
export LC_PAPER=en_GB.UTF-8
export LC_NAME=cs_CZ.UTF-8
export LC_ADDRESS=cs_CZ.UTF-8
export LC_TELEPHONE=cs_CZ.UTF-8
export LC_MEASUREMENT=en_GB.UTF-8
export LC_IDENTIFICATION=cs_CZ.UTF-8

export VAGRANT_HOME=~/vagrants/vagrant.d

export PURE_CMD_MAX_EXEC_TIME=10000

# Force zsh to jump over words as in bash (using M-f and M-b on command line)
export WORDCHARS=''


# Names of i3wm workspaces
export WS_1="1:  "
export WS_2="2:  "
export WS_3="3:  "
export WS_4="4:  "
export WS_5="5:  "
export WS_6="6:  "
export WS_7="7:  "
export WS_8="8:  "
export WS_9="9:  "
export WS10="10: "
export WS11="11: "

