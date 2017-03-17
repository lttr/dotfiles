Idempotent installation for multiple types of packages
======================================================

_Proposal for `packs` utility._

_Show me **installed** packages and the ones I have **configured** to be
installed. If there are **missing** packages, **install** them. Show me which
packages can be **updated** and **update** them._

_If I want to install and update everything just **process** my configuration._


## Why

I want to perform following actions for every group of packages

* list installed packages `packs installed <type>`
* list packages that should be installed according to configuration `packs configured <type>`
* list missing packages according to configuration `packs missing <type>`
* install packages which are not yet installed and list them `packs install <type>`
* list packages that are installed but can be updated `packs updatable <type>`
* update packages and list which got update `packs update <type>`
* process everything `packs process <type>`

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
    fzf/install
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

### Ubuntu

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
?
```

**update**
```
yarn global upgrade
```
