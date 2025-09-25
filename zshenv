#             _
#            | |
#   ____ ___ | |__    ___  _ __ __   __
#  |_  // __|| '_ \  / _ \| '_ \\ \ / /
#   / / \__ \| | | ||  __/| | | |\ V /
#  /___||___/|_| |_| \___||_| |_| \_/
#

# Profiling start
# zmodload zsh/zprof

# zsh
export ZSH_DIR="$HOME/.zsh"
# jump over whole words
export WORDCHARS='`~!@#$%^&*()-_=+[{]};:\"\|,<.>/?'

# Nuxt framework specific
# prevent it from failing on my machine
export NUXT_TELEMETRY_DISABLED=1

# open in my editor of choice for https://github.com/yyx990803/launch-editor
export LAUNCH_EDITOR="open-neovim"

# PATH

# my bin folders
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# fnm
export PATH="$HOME/.local/share/fnm:$PATH"

# fnm env caching - regenerate once per day to avoid 300ms startup delay
# Cache the output of 'fnm env' to avoid running it on every shell startup
FNM_CACHE="$HOME/.cache/fnm/env_cache.zsh"
# Check if cache doesn't exist or was created before today
if [[ ! -f "$FNM_CACHE" ]] || [[ $(date -r "$FNM_CACHE" +%Y%m%d 2>/dev/null) != $(date +%Y%m%d) ]]; then
  mkdir -p "$(dirname "$FNM_CACHE")"
  fnm --log-level=error env --use-on-cd > "$FNM_CACHE"
fi
# Source the cached fnm environment
source "$FNM_CACHE"

# deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# brew - direct path setup to save ~286ms on startup
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}"
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"
  [ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
fi

# vscode
export PATH=$PATH:/usr/share/code

# forgit
export PATH="$PATH:$FORGIT_INSTALL_DIR/bin"

# ripgrep
export RIPGREP_CONFIG_PATH=$HOME/dotfiles/ripgrep_config

# dotnet
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$DOTNET_ROOT"
export PATH="$PATH:$DOTNET_ROOT/tools" # for photo-cli

# user environment
export PAGER=/usr/bin/less
export EDITOR=nvim
export VISUAL=nvim
export BROWSER=/usr/bin/firefox

# user locale
export LANG=en_US.UTF8
export LANGUAGE=en_US.UTF8
export LC_ALL=en_US.UTF8
export LC_CTYPE=en_US.UTF8
export LC_NUMERIC=en_US.UTF8
# export LC_TIME=cs_CZ.UTF8
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
export PURE_CMD_MAX_EXEC_TIME=2000

# Profiling end
# zprof
