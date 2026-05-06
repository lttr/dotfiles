# CLAUDE.md

Personal dotfiles for PopOS/Ubuntu. Deployed via symlinks.

## Layout

- `zshrc`/`zshenv`/`aliases`/`functions` - shell config
- `kitty.conf`, `gitconfig`, `nvim/`, `atuin/`, `ranger/` - tool configs
- `bootstrap/` - Deno-based installer (TS tasks under `configuration/`)
- `claude/` - Claude Code config (commands, agents, hooks, scripts)
- `scripts/<category>/` - utility scripts (shell/, git/, dev/, graphics/, ...)

## Workflow

- Install: `install.sh` (bootstrap + symlinks), `symlinks.sh` (symlinks only)
- Edit in `~/dotfiles`, not symlinked locations. Reload: new shell or `source ~/dotfiles/zshrc`
- `scripts/<category>/*.{sh,ts,js}` auto-symlinked to `~/bin`

## Deps

Zsh + antidote, Kitty, Neovim, fzf, ripgrep, fd, eza, zoxide, atuin, Deno.
