#!/usr/bin/env bash

#
# Install custom packages and programs from various internet sources
#
# Custom apt repositories will added but the packages have to be installed
# and managed elsewhere with other .deb packages.
#

MY_APPS_DIR=${HOME}/opt


log_installing() {
    echo
    echo "=================================================="
    echo "Installing $1"
    echo "=================================================="
}

already_installed() {
    echo "$1 already installed"
}

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

check_custom_app() {
    if command_exists "$1"; then
        already_installed "$1"
        return 1
    else
        log_installing "$1"
        return 0
    fi
}


cd $MY_APPS_DIR


#Program zsh plugin manager
if check_custom_app 'antibody'; then
    curl -s https://raw.githubusercontent.com/getantibody/installer/master/install \
        | bash -s
fi

#Program docker
if check_custom_app 'docker'; then
    curl -sSL https://get.docker.com/ | sh
    sudo usermod -aG docker `whoami`
fi

#Program fasd
if check_custom_app 'fasd'; then
    tar zxv < <(wget -q -O - https://github.com/clvv/fasd/archive/1.0.1.tar.gz)
    cd fasd-1.0.1
    sudo make install
    cd $MY_APPS_DIR
fi

#Program fzf
if check_custom_app 'fzf'; then
    git clone --depth 1 https://github.com/junegunn/fzf.git
    fzf/install
fi

#Program git credential helper
if check_custom_app 'git-credential-gnome-keyring'; then
    git clone git://github.com/pah/git-credential-helper.git
    sudo apt-get install -y libgnome-keyring-dev
    BACKEND=gnome-keyring
    cd git-credential-helper/$BACKEND
    make
    cp git-credential-$BACKEND ~/bin/
    cd $MY_APPS_DIR
fi

#Program gdrive
if check_custom_app 'gdrive'; then
    wget -O gdrive "https://drive.google.com/uc?id=0B3X9GlR6Embnb095MGxEYmJhY2c"
    chmod +x gdrive
    ln -fs ~/opt/gdrive ~/bin/gdrive
fi

#Program google chrome
if check_custom_app 'google-chrome'; then
    if grep -Fxq "deb http://dl.google.com/linux/chrome/deb/ stable main" \
        /etc/apt/sources.list.d/google-chrome.list
    then
        : # Already set
    else
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub \
            | sudo apt-key add -
        sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" \
            >> /etc/apt/sources.list.d/google-chrome.list'
    fi
fi

#Program hub
if check_custom_app 'hub'; then
    HUB_VER=2.2.9
    wget -q https://github.com/github/hub/releases/download/v${HUB_VER}/hub-linux-amd64-${HUB_VER}.tgz
    tar zxf hub-linux-amd64-${HUB_VER}.tgz
    sudo ./hub-linux-amd64-${HUB_VER}/install
    rm -rf hub-linux-amd64-${HUB_VER}
    rm -rf hub-linux-amd64-${HUB_VER}.tgz
fi

#Program neovim
if check_custom_app 'nvim'; then
    sudo add-apt-repository -y ppa:neovim-ppa/stable
fi

#Program nodejs
if check_custom_app 'nodejs'; then
    curl -sSL https://deb.nodesource.com/setup_8.x | sudo -E bash -
fi

#Program infinality
if ! apt-mark showmanual | grep -q fontconfig-infinality; then
    sudo add-apt-repository -y ppa:no1wantdthisname/ppa
fi

#Program skype
if check_custom_app 'skype'; then
    sudo add-apt-repository -y "deb http://archive.canonical.com/ubuntu $(lsb_release -sc) partner"
fi

#Program tmux plugin manager
if [ ! -d ~/.tmux/plugins/tpm ]; then
    log_installing 'tmux-plugin-manager'
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

#Program vim plugin manager
if which vim >/dev/null 2>&1; then
    curl -sSLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

#Program yarn
if check_custom_app 'yarn'; then
    curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    sudo add-apt-repository -y "deb https://dl.yarnpkg.com/debian/ stable main"
fi

#Program xkblayout-state
if ! [ -x $HOME/.i3/scripts/xkblayout-state ]; then
    git clone https://github.com/nonpop/xkblayout-state.git
    cd xkblayout-state
    make
    cd $MY_APPS_DIR
    ln -sf $MY_APPS_DIR/xkblayout-state/xkblayout-state ~/.i3/scripts/xkblayout-state
fi



# ===== Deprecated =====

# if check_custom_app 'gsettings-info'; then
#     git clone https://github.com/jmatsuzawa/gsettings-info
#     ln -sf $MY_APPS_DIR/gsettings-info/gsettings-info ~/bin/gsettings-info
# fi

# if check_custom_app 'sdkman'; then
#     export SDKMAN_DIR="${MY_APPS_DIR}/sdkman" && curl -s "https://get.sdkman.io" | bash
# fi

# if check_custom_app 'vivaldi'; then
#     git clone https://gist.github.com/b5aca855f2d05ba14836.git vivaldi-install
#     cd vivaldi-install
#     sudo sh install-vivaldi.sh --snapshot
#     sudo mv /usr/local/bin/vivaldi-snapshot /usr/local/bin/vivaldi
#     cd $MY_APPS_DIR
# fi
