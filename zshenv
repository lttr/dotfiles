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
if uname -a | grep -i Microsoft >/dev/null; then
    export WSL=true
else
    export WSL=false
fi

# PATH

# user path
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# nodejs path
NPM_GLOBAL="$HOME/.npm-global"
export PATH="$NPM_GLOBAL/bin:$PATH"

# nodejs switch tool install location
export N_PREFIX=/home/lukas/.n
export PATH="$N_PREFIX/bin:$PATH"

# deno path
export DENO_INSTALL="/home/lukas/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# go path
export GOPATH="$HOME/.go"
export GOROOT="/usr/local/go"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"

# vsts
export PATH=$PATH:$HOME/opt/vsts-cli/bin

# prefer /usr/bin than Windows PATH
if [[ $WSL = true ]]; then
  export PATH="$PATH:/usr/bin"
fi


# vagrant
export VAGRANT_HOME=~/vagrants/vagrant.d

# man pages

unset MANPATH # only once here
export MANPATH="$NPM_GLOBAL/share/man:$(manpath)"


# user environment
export PAGER=/usr/bin/less
#export EDITOR=/usr/bin/vim
export EDITOR=code
export VISUAL=/usr/bin/vim
export BROWSER=/usr/bin/google-chrome
# export TERMINAL=/usr/bin/urxvt
# export TERM=rxvt-unicode-256color

# user locale
export LANG=en_US.utf8
export LANGUAGE=en_US.utf8
export LC_CTYPE=en_US.utf8
export LC_NUMERIC=en_US.utf8
export LC_TIME=en_GB.utf8
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

