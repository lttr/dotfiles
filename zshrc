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
HISTSIZE=100000
HISTFILESIZE=100000
SAVEHIST=100000
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


fpath+=(~/.zsh/completion)
fpath+=("$(brew --prefix)/share/zsh/site-functions")

source <(npm completion)

autoload bashcompinit && bashcompinit
[ -d ~/opt/azure-cli ] && source ~/opt/azure-cli/az.completion


# =================================================================
#                             Colors
# =================================================================

eval $(dircolors ~/dotfiles/colors/dircolors)

LIST_FILES_COMMAND='fd --hidden --no-ignore --exclude .git --exclude node_modules --exclude build/ --exclude dist/ --exclude .lock'

# Numbers represent terminal colors, see kitty.conf
# bg+ is background color for active item (same color as selection in my vim)
export FZF_DEFAULT_OPTS="
  --color bg:#2d2d2d,hl:#d8a657,bg+:#45403d,hl+:#d8a657
  --color pointer:1,info:8,spinner:8,header:8,prompt:12,marker:#d8a657
  --exit-0
  --select-1
  --reverse
  --height=30
  "
export FZF_CTRL_T_COMMAND=$LIST_FILES_COMMAND

export forgit_log=fglo
export forgit_diff=fgd
export forgit_add=fga
export forgit_reset_head=fgres # git restore --staged
export forgit_ignore=fgi
export forgit_checkout_file=fgre # git restore
export forgit_checkout_branch=fgcb
export forgit_branch_delete=fgbd
export forgit_checkout_tag=fgct
export forgit_checkout_commit=fgco
export forgit_revert_commit=fgrc
export forgit_clean=fgclean
export forgit_stash_show=fgss
export forgit_cherry_pick=fgcp
export forgit_rebase=fgrb
export forgit_blame=fgbl
export forgit_fixup=fgfu
  
export FORGIT_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height=100%"

export MC_SKIN=/home/lukas/.config/mc/solarized-light.ini

export BAT_THEME="TwoDark"
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

# My terminal (kitty now) for some reason does not display tab title according to pure prompt logic

precmd () {
  kitty @ set-tab-title "$(basename $(dirname ${PWD}))/$(basename ${PWD})"
}

preexec() {
  kitty @ set-tab-title "$(basename $(dirname ${PWD}))/$(basename ${PWD}): $1"
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

source ~/dotfiles/functions
source ~/dotfiles/aliases


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

[[ -f ~/.functions.local ]] && source ~/.functions.local
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.aliases.local ]] && source ~/.aliases.local


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


# The next line updates PATH for Netlify's Git Credential Helper.
if [ -f '/home/lukas/.netlify/helper/path.zsh.inc' ]; then source '/home/lukas/.netlify/helper/path.zsh.inc'; fi

# Profiling
# zprof


#find-alias
[[ -s "$HOME/.find-alias.sh" ]] && source "$HOME/.find-alias.sh"
