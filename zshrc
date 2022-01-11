#             _
#            | |
#   ____ ___ | |__   _ __  ___
#  |_  // __|| '_ \ | '__|/ __|
#   / / \__ \| | | || |  | (__
#  /___||___/|_| |_||_|   \___|
#

# Profiling
# zmodload zsh/zprof

# =================================================================
#                            Autoload
# =================================================================

autoload -U history-search-end
autoload -U zmv
autoload -Uz compinit


# =================================================================
#                           Shortcuts
# =================================================================

bindkey -e

# Do not catch Ctrl+q and Ctrl+s by the terminal
# (I use it in vim)
stty start undef
stty stop undef

# Alt+i to search inside files
zle -N file-search
bindkey '^[i' file-search

# Alt+e to open recent files
zle -N file-recent
bindkey '^[e' file-recent

# Alt+p to open file in subdirectories
zle -N file-edit
bindkey '^[p' file-edit

# Alt+d to go to recent (almost any reasonable) directory
zle -N dir-recent
bindkey '^[d' dir-recent

# Alt+j to go to any subdirectory
zle -N dir-open
bindkey '^[j' dir-open


# Alt+l to copy last command into clipboard
zle -N last-command
bindkey '^[l' last-command

# Alt+n to edit command line
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^[n' edit-command-line

# Alt+o to insert last command output
zle -N insert-last-output
bindkey '^[o' insert-last-output

# Alt+Backspace to remove last path segment (like in bash)
bindkey "^[^?" vi-backward-kill-word

# Alt+a accept-and-hold = execute line and keep editing the line
# Alt+b backward-word
# Alt+c fzf-cd-widget = jump to directory via fzf
# Alt+f forward-word
# Alt+g get-line = insert line from buffer
# Alt+h run-help = man page for command under cursor
# Alt+m = urxvt: list all urls in terminal
# Alt+q push-line
# Alt+r = urxvt: activate search
# Alt+s = urxvt: scrollback search
# Alt+t transpose-words
# Alt+u = urxvt: open last url in terminal
# Alt+v = urxvt: activate vim movement
# Alt+w copy-region-as-kill
# Alt+x execute-named-cmd
# Alt+y yank-pop
# Alt+z execute-last-named-cm


# =================================================================
#                            Options
# =================================================================

# append history list to the history file (important for multiple parallel zsh sessions!)
setopt inc_append_history
# import new commands from the history file also in other zsh-session
setopt share_history
# save each command's beginning timestamp and the duration to the history file
setopt extended_history
# if a new command line being added to the history list duplicates an older one, the older command is removed from the list
setopt hist_ignore_all_dups
# remove command lines from the history list when the first character on the line is a space
setopt hist_ignore_space
# allow more patterns to be expanded on command line
setopt extended_glob
# disable beeping (e.g. after tab completion)
unsetopt beep

HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
KEYTIMEOUT=1

# =================================================================
#                           Completion
# =================================================================

# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'


fpath=(~/.zsh/completion $fpath)
fpath=(~/.local/opt/brew/share/zsh/site-functions $fpath)

source <(npm completion)

autoload bashcompinit && bashcompinit
[ -d ~/opt/azure-cli ] && source ~/opt/azure-cli/az.completion


# =================================================================
#                             Colors
# =================================================================

eval $(dircolors ~/dotfiles/colors/dircolors)

        # --color=bg+:#eaeaea,bg:#c5c8c6,spinner:#719e07,hl:#002b36
        #
_gen_fzf_default_opts() {
    if [[ $WSL == true ]]; then
        export FZF_DEFAULT_OPTS="
        --color=bg+:#eee8d5,bg:#fdf6e3,spinner:#719e07,hl:#002b36
        --color=fg:#657b83,header:#586e75,info:#586e75,pointer:#719e07
        --color=marker:#719e07,fg+:#657b83,prompt:#b58900,hl+:#002b36
        --exit-0
        --select-1
        --reverse
        --height=30
        "
    else
        export FZF_DEFAULT_OPTS="
        --color fg+:$sol_code_base01,bg+:$sol_code_base2,hl:$sol_code_yellow,hl+:$sol_code_yellow
        --exit-0
        --select-1
        --reverse
        --height=30
        "
    fi
    export FZF_CTRL_T_COMMAND='ag -g ""'
}
_gen_fzf_default_opts

export MC_SKIN=/home/lukas/.config/mc/solarized-light.ini

export BAT_THEME="base16"
export BAT_PAGER="less -RF"


# =================================================================
#                            Plugins
# =================================================================

# Antibody
source <(antibody init)
antibody bundle < ~/dotfiles/packages/zsh.txt

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide
eval "$(zoxide init zsh)"

# =================================================================
#                           Terminal
# =================================================================

# Write some info to terminal title.
# This is seen when the shell prompts for input.
function precmd {
  print -Pn "\e]0;zsh%L %(1j,%j job%(2j|s|); ,)%~\a"
}
# Write command and args to terminal title.
# This is seen while the shell waits for a command to complete.
function preexec {
  printf "\033]0;%s\a" "$1"
}

if [[ $WSL != "true" ]]; then
  xrdb -load ~/.Xresources
fi

# =================================================================
#                          Directories
# =================================================================

# Save current working directory into file.
# Called by zsh every time current working directory is changed.
chpwd() {
  echo "$PWD" > ~/.cwd
}


# =================================================================
#                    Aliases and functions
# =================================================================

source ~/dotfiles/aliases
source ~/dotfiles/functions


# =================================================================
#                          WSL config
# =================================================================

if [[ $WSL == "true" ]]; then
    source ~/dotfiles/zshenv.wsl
    source ~/dotfiles/zshrc.wsl
    source ~/dotfiles/aliases.wsl
fi


# =================================================================
#                          Local config
# =================================================================

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.aliases.local ]] && source ~/.aliases.local
[[ -f ~/.functions.local ]] && source ~/.functions.local


# =================================================================
#                        History database
# =================================================================

# source ~/opt/bash_database_history/zsh_trap.sh

# =================================================================
#                          Last command
# =================================================================

# Source: https://gist.github.com/ctechols/ca1035271ad134841284
# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit;
else
  compinit -C;
fi;


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


# The next line updates PATH for Netlify's Git Credential Helper.
if [ -f '/home/lukas/.netlify/helper/path.zsh.inc' ]; then source '/home/lukas/.netlify/helper/path.zsh.inc'; fi

# Profiling
# zprof
