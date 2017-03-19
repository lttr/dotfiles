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


# =================================================================
#                           Shortcuts
# =================================================================



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
antibody bundle < ~/dotfiles/antibody/bundles.txt

# Fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Fasd
eval "$(fasd --init auto)"


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


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/opt/sdkman"
[[ -s "$HOME/opt/sdkman/bin/sdkman-init.sh" ]] && source "$HOME/opt/sdkman/bin/sdkman-init.sh"
