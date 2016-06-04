#!/usr/bin/env zsh
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

export PAGER=/usr/bin/less
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim
export BROWSER=/usr/bin/vivaldi

export LANG=en_US.UTF-8
export LC_NUMERIC=cs_CZ.UTF-8
export LC_TIME=en_GB.UTF-8
export LC_MONETARY=cs_CZ.UTF-8

