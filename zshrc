export PATH=$HOME/bin:$PATH

source ~/.aliases

source <(antibody init)

antibody bundle < ~/dotfiles/antibody/bundles.txt

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(fasd --init auto)"

export EDITOR=vi

export LANG=en_US.UTF-8
export LC_NUMERIC=cs_CZ.UTF-8
export LC_TIME=en_GB.UTF-8
export LC_MONETARY=cs_CZ.UTF-8

# Do not catch Ctrl+q and Ctrl+s by the terminal
# (I use it in vim)
stty start undef
stty stop undef

if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi
