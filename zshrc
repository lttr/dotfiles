#             _
#            | |
#   ____ ___ | |__   _ __  ___
#  |_  // __|| '_ \ | '__|/ __|
#   / / \__ \| | | || |  | (__
#  /___||___/|_| |_||_|   \___|
#

# =================================================================
#                            Autoload
# =================================================================

autoload -U history-search-end
autoload -U zmv

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
autoload -Uz compinit 
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;


# =================================================================
#                           Shortcuts
# =================================================================

bindkey -e

# Do not catch Ctrl+q and Ctrl+s by the terminal
# (I use it in vim)
stty start undef
stty stop undef

# Alt+Shift+f to search inside files
zle -N file-search
bindkey '^[F' file-search

# Alt+Shift+e to open recent files
zle -N file-recent
bindkey '^[E' file-recent

# Alt+Shift+p to open file in subdirectories
zle -N file-edit
bindkey '^[P' file-edit

# Alt+Shift+g to open file using global locate
zle -N file-locate
bindkey '^[G' file-locate

# Alt+Shift+r to go to recent (almost any reasonable) directory
zle -N dir-recent
bindkey '^[R' dir-recent

# Alt+Shift+j to go to any subdirectory 
zle -N dir-open
bindkey '^[J' dir-open


# Alt+Shift+c to copy last command into clipboard
zle -N last-command
bindkey '^[C' last-command

# Edit command line
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^[V" edit-command-line


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

# source <(ng completion --zsh)


# =================================================================
#                    Aliases and functions
# =================================================================

source ~/dotfiles/aliases
source ~/dotfiles/functions


# =================================================================
#                             Colors
# =================================================================

eval $(dircolors ~/dotfiles/colors/dircolors)

_gen_fzf_default_opts() {
  # Solarized colors
  local base03="234"
  local base02="235"
  local base01="240"
  local base00="241"
  local base0="244"
  local base1="245"
  local base2="254"
  local base3="230"
  local yellow="136"
  local orange="166"
  local red="160"
  local magenta="125"
  local violet="61"
  local blue="33"
  local cyan="37"
  local green="64"

  export FZF_DEFAULT_OPTS="
    --color fg+:$base01,bg+:$base2,hl:$yellow,hl+:$yellow
  "
  export FZF_CTRL_T_COMMAND='ag -g ""'
}
_gen_fzf_default_opts

export MC_SKIN=/home/lukas/.config/mc/solarized-light.ini


# =================================================================
#                            Plugins
# =================================================================

# Antibody
source <(antibody init)
antibody bundle < ~/dotfiles/packages/zsh.txt

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fasd
eval "$(fasd --init auto)"

# git
source $HOME/opt/git-hub/.rc


# =================================================================
#                          Directories
# =================================================================

# Save current working directory into file.
# Called by zsh every time current working directory is changed.
chpwd() {
  echo "$PWD" > ~/.cwd
}


# =================================================================
#                          Local config
# =================================================================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.aliases.local ]] && source ~/.aliases.local
[[ -f ~/.functions.local ]] && source ~/.functions.local

