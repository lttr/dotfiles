#             _
#            | |
#   ____ ___ | |__   _ __  ___
#  |_  // __|| '_ \ | '__|/ __|
#   / / \__ \| | | || |  | (__
#  /___||___/|_| |_||_|   \___|
#


# =================================================================
#                            Options
# =================================================================


autoload -U history-search-end

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
#                              Keys
# =================================================================

bindkey -e

# Do not catch Ctrl+q and Ctrl+s by the terminal
# (I use it in vim)
stty start undef
stty stop undef


# =================================================================
#                    Aliases and functions
# =================================================================

source ~/dotfiles/aliases
source ~/dotfiles/functions


# =================================================================
#                             Colors
# =================================================================

eval $(dircolors ~/dotfiles/dircolors)


# =================================================================
#                            Plugins
# =================================================================

source <(antibody init)

antibody bundle < ~/dotfiles/antibody/bundles.txt

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(fasd --init auto)"


# =================================================================
#                          Local config
# =================================================================

[[ -f ~/.zshrc_local ]] && source ~/.zshrc_local
