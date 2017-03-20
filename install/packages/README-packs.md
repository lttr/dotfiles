Idempotent installation for multiple types of packages
======================================================

_Proposal for `packs` utility._

_Show me **installed** packages and the ones I have **configured** to be
installed. If there are **missing** packages, **install** them. Show me which
packages can be **updated** and **update** them._

_If I want to install and update everything just **process** my configuration._


## Why

I want to perform following actions for every group of packages

* List installed packages `packs installed <type>`
* List packages that should be installed according to configuration `packs configured <type>`
* List missing packages according to configuration `packs missing <type>`
* Install packages which are not yet installed and list them `packs install <type>`
* List packages that are installed but can be updated `packs updatable <type>`
* Update packages and list which got update `packs update <type>`
* Install everything missing and update every package `packs process <type>`

`<type>` is the package type or keyword `all` for every known type.


## Package types

| system          | type       | manager    |
| --              | --         | --         |
| ubuntu packages | **ubuntu**     | `apt-get`  |
| node packages   | **node**       | `yarn`     |
| python packages | **python**     | `pip`      |
| vim plugins     | **vim**        | `vim-plug` |
| zsh plugins     | **zsh**        | `antibody` |
| custom repos    | **submodule**  | `git`      |
| custom apps     | **custom**     | `bash`     |

## Lists of packages with examples

ubuntu.packs
```
tmux
zsh
```

node.packs
```
gulp
@angular/cli
```

python.packs
```
csvkit
pandas
```

plugins.vim
```
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf', { 'do': './install --all' }
```

zsh.packs
```
zsh-users/zsh-completions
sindresorhus/pure
```

.gitmodules
```
[submodule "dotbot"]
	path = dotbot
	url = https://github.com/anishathalye/dotbot
```

custom.packs
```
if check_custom_app 'antibody'; then
    curl -s https://raw.githubusercontent.com/getantibody/installer/master/install | bash -s
fi
if check_custom_app 'fzf'; then
    git clone --depth 1 https://github.com/junegunn/fzf.git
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

Note: `yarn` is quicker but `npm` is fine

**installed**
```
yarn global ls
yarn global ls --json 2>/dev/null | jq -cr 'select(.type | test("info")) | .data | split("\"")| .[1]'
```

**configured**
```
cat node.packs
```

**missing**
```
yarn global list
cat node.packs
sort -u
comm -23
```

**install**
```
yarn global add …
```

**updatable**
```
! not implemented in yarn yet (3/2017) !
yarn global outdated
```

**update**
```
yarn global upgrade
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
