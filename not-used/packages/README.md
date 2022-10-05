Idempotent installation of different types of packages
======================================================

_Implemented in `packs.sh` script._

> Show me **installed** packages and the ones I have **configured** to be
> installed. If there are **missing** packages, **install** them. Show me which
> packages can be **updated** and **update** them. If I need to investigate
> show me the **history** of installations. If I want to install and update 
> everything just **process** my configuration. Are there anything I installed 
> **extra**?


## Why

I want to perform following actions for different types of packages and package
managers. Who can remember all those commands?

* List history of installations `packs <type> history`
* List installed packages `packs <type> installed`
* List packages that should be installed according to configuration `packs <type> configured`
* List missing packages according to configuration `packs <type> missing`
* List extra packages according to configuration `packs <type> extra`
* Install packages which are not yet installed and list them `packs <type> install`
* List packages that are installed but can be updated `packs <type> updatable`
* Update packages and list which got update `packs <type> update`
* Install everything missing and update every package `packs <type> process`

## Package types

| system          | type       | manager    |
| --              | --         | --         |
| ubuntu packages | **ubuntu**     | `apt-get`  |
| node packages   | **node**       | `npm`     |
| python packages | **python**     | `pip`      |
| vim plugins     | **vim**        | `vim-plug` |
| zsh plugins     | **zsh**        | `antibody` |
| custom repos    | **submodule**  | `git`      |
| custom apps     | **custom**     | `bash`     |

## Examples of packages

#### ubuntu / apt packages
```
tmux
zsh
```

#### nodejs packages
```
gulp
@angular/cli
```

#### python packages
```
csvkit
pandas
```

#### vim plugins
```
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'do': './install --all' }
```

#### zsh plugins
```
zsh-users/zsh-completions
sindresorhus/pure
```

#### .gitmodules
```
[submodule "dotbot"]
	path = dotbot
	url = https://github.com/anishathalye/dotbot
```

#### custom programs
```
# Vim plugin manager
if which vim >/dev/null 2>&1; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
```


## How

### Ubuntu

Note: `apt-get`, `apt-cache` and `dpkg` for scripting, `apt` for humans.

**installed**
```
apt list --installed
```

**configured**
```
cat ubuntu.packs
```

**missing**
```
apt-list()
cat ubuntu.packs
sort -u
comm -23
```

**install**
```
sudo apt install <missing>
```

**updatable**
```
apt list --upgradable
```

**update**
```
sudo apt full-upgrade
```

### Node

Note: (`yarn` is no longer quicker but) `npm` is fine

**installed**
```
npm ls -g --depth=0
npm ls -g --depth=0 -parseable \
    | grep 'node_modules' \
    | sed -e 's@^.*node_modules/@@'
```

**configured**
```
cat node.packs
```

**missing**
```
npm ls -g --depth=0
cat node.packs
sort -u
comm -23
```

**install**
```
npm ls -g --depth=0
```

**updatable**
```
npm outdated -g
```

**update**
```
npm update -g
```

### Python

**installed**
```
pip list
pip list 2>/dev/null | awk '{print $1}' | sort
```

**configured**
```
cat python.packs
cat python.packs | sort
```

**missing**
```
comm -13 \
  <(pip list 2>/dev/null | awk '{print $1}' | sort) \
  <(cat python.packs | sort)
```

**install**
```
pip install -r python.packs
```

**updatable**
```
pip list --outdated
```

extra
```
comm -23 \
  <(pip list 2>/dev/null | awk '{print $1}' | sort) \
  <(cat python.packs | sort)
```


**update**
```
pip install --requirement python.packs --upgrade
```

### Zsh plugins


**installed**
```
antibody list
antibody list | awk -F'-SLASH-' '{print $4"/"$5}' | sort
```

**configured**
```
cat zsh.packs
```

**missing**
```
comm -13 \
  <(antibody list | awk -F'-SLASH-' '{print $4"/"$5}' | sort) \
  <(cat zsh.packs | sort)
```

**install**
```
git submodule add
```

**updatable**
```
cd `antibody home`
git-rs (recursive status)
```

**update**
```
antibody update
```

**extra**
```
comm -23 \
  <(antibody list | awk -F'-SLASH-' '{print $4"/"$5}' | sort) \
  <(cat zsh.packs | sort)
```


### Submodules

Git submodules are hard and error prone. Better to understand them well and
manage them with git commands.

**installed**
```
git submodule foreach
```

**configured**
```
git config --file .gitmodules --name-only --get-regexp path
cat .gitmodules
```

**missing**
```
git config --get-regexp submodule
git submodule status --recursive | grep '^-'
```

**install**
```
git submodule add
```

**updatable**
```
git config status.submoduleSummary true
git status
git submodule status --recursive
```

**update**
```
git submodule update --init
```
