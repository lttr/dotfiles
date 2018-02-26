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

# is this inside Windows subsystem for Linux
if uname -a | grep Microsoft >/dev/null; then
    WSL=true
else
    WSL=false
fi

# user path
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

# nodejs path
export PATH="$PATH:$HOME/.yarn-global/bin"
export PATH="$PATH:$HOME/.yarn/bin"
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
export LANG=en_US.utf8
export LANGUAGE=en_US.utf8
export LC_CTYPE=en_US.utf8
export LC_NUMERIC=en_US.utf8
export LC_TIME=en_US.utf8
export LC_COLLATE=en_US.utf8
export LC_MONETARY=en_US.utf8
export LC_MESSAGES=en_US.utf8
export LC_PAPER=en_US.utf8
export LC_NAME=en_US.utf8
export LC_ADDRESS=en_US.utf8
export LC_TELEPHONE=en_US.utf8
export LC_MEASUREMENT=en_US.utf8
export LC_IDENTIFICATION=en_US.utf8

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

# Solarized light colors
sol_code_base03="234"
sol_code_base02="235"
sol_code_base01="240"
sol_code_base00="241"
sol_code_base0="244"
sol_code_base1="245"
sol_code_base2="254"
sol_code_base3="230"
sol_code_yellow="136"
sol_code_orange="166"
sol_code_red="160"
sol_code_magenta="125"
sol_code_violet="61"
sol_code_blue="33"
sol_code_cyan="37"
sol_code_green="64"

