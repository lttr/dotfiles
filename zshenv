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

# Generated for envman. DEPRECATED? Used by webinstall?
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# my bin folders
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# fnm
export PATH=/home/lukas/.fnm:$PATH
which fnm >/dev/null && eval "$(fnm env --use-on-cd)"

# deno
export DENO_INSTALL="/home/lukas/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# brew
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}";
[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# vscode
export PATH=$PATH:/usr/share/code

# forgit
export PATH="$PATH:$FORGIT_INSTALL_DIR/bin"

# user environment
export PAGER=/usr/bin/less
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=/usr/bin/google-chrome

# user locale
export LANG=en_US.UTF8
export LANGUAGE=en_US.UTF8
export LC_CTYPE=en_US.UTF8
export LC_NUMERIC=en_US.UTF8
export LC_TIME=cs_CZ.UTF8
export LC_COLLATE=en_US.UTF8
export LC_MONETARY=en_US.UTF8
export LC_MESSAGES=en_US.UTF8
export LC_PAPER=en_US.UTF8
export LC_NAME=en_US.UTF8
export LC_ADDRESS=en_US.UTF8
export LC_TELEPHONE=en_US.UTF8
export LC_MEASUREMENT=en_US.UTF8
export LC_IDENTIFICATION=en_US.UTF8

# user prompt
export PURE_CMD_MAX_EXEC_TIME=10000

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

