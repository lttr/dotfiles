#             _
#            | |
#   ____ ___ | |__    ___  _ __ __   __
#  |_  // __|| '_ \  / _ \| '_ \\ \ / /
#   / / \__ \| | | ||  __/| | | |\ V /
#  /___||___/|_| |_| \___||_| |_| \_/
#


if [ -d "$HOME/bin" ] ; then
    export PATH="$HOME/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
fi

export PAGER=/usr/bin/less
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim
export BROWSER=/usr/bin/vivaldi
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
