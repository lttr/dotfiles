#             _
#            | |
#   ____ ___ | |__    ___  _ __ __   __
#  |_  // __|| '_ \  / _ \| '_ \\ \ / /
#   / / \__ \| | | ||  __/| | | |\ V /
#  /___||___/|_| |_| \___||_| |_| \_/
#

# zsh
export ZSH_DIR="$HOME/.zsh"
# jump over whole words
export WORDCHARS='`~!@#$%^&*()-_=+[{]};:\"\|,<.>/?'

# user path
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

# nodejs path
export PATH="$PATH:$HOME/.yarn-global/bin"
export PATH="$PATH:$HOME/.npm-global/bin"

# go path
export GOPATH="$HOME/.go"
export GOROOT="/usr/local/go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

# vsts
export PATH=$PATH:$HOME/opt/vsts-cli/bin

# vagrant
export VAGRANT_HOME=~/vagrants/vagrant.d

# user environment
export PAGER=/usr/bin/less
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim
export BROWSER=/usr/bin/google-chrome
export TERMINAL=/usr/bin/urxvt
export TERM=rxvt-unicode-256color

# user locale
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
# export LC_ALL=C

# user prompt
export PURE_CMD_MAX_EXEC_TIME=10000
if [[ $(hostname) == 'lttr-win10' ]]; then
    export PURE_PROMPT_SYMBOL=$
    export PURE_GIT_UP_ARROW=^
    export PURE_GIT_DOWN_ARROW=v
fi

# i3wm workspaces
export WS_1="1:  "
export WS_2="2:  "
export WS_3="3:  "
export WS_4="4:  "
export WS_5="5:  "
export WS_6="6:  "
export WS_7="7:  "
export WS_8="8:  "
export WS_9="9:  "
export WS10="10: "
export WS11="11: "

