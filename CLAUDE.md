# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for managing development machine configuration, shell customization, and automation scripts. Structured for PopOS/Ubuntu-based systems using symbolic links for deployment.

## Project Structure

### Core Configuration Files

- `zshrc` - Main zsh configuration (sources aliases, functions, plugins)
- `zshenv` - Environment variables and PATH configuration
- `aliases` - Shell aliases (navigation, git, npm, shortcuts)
- `functions` - Shell functions (interactive utilities, fzf integrations, git helpers)
- `kitty.conf` - Kitty terminal emulator configuration
- `gitconfig` - Git configuration and aliases

### Key Directories

- `bootstrap/` - TypeScript installation system (Deno-based)
  - `configuration/` - Installation task definitions
  - Run via `install.sh` to set up new machines
- `claude/` - Claude Code configuration (commands, agents, hooks, scripts)
- `scripts/` - Utility scripts organized by category (shell/, git/, dev/, graphics/, etc.)
- `nvim/` - Neovim configuration
- `atuin/`, `ranger/` - Additional tool configurations

## Shell Architecture

### Smart Functions with fzf

- `l` - Smart list function (auto-detects file type):
  - Directory → `eza` listing
  - Text file → `batcat` preview (first 40 lines)
  - Archive (zip, tar.*) → list contents
  - Image (png, jpg, etc.) → render in terminal with kitty icat
- `dr`/`dir-recent` - Jump to recent directories (zoxide + fzf)
- `fe`/`file-recent` - Edit recently opened nvim files (fzf)
- `file-search` - Interactive ripgrep search with fzf, opens vim at matched line

### Git Workflow

**Default branch detection** (`git_default_branch()` in `aliases`):
1. Check `.git/default_branch` file
2. Query `refs/remotes/origin/HEAD`
3. Run `git remote show origin`
4. Fallback to "master"

**Key git functions/aliases:**
- `gst()` - Git status with fallback to file listing (defined in `functions`)
- `gcom()` - Switch to default branch (intelligently detected)
- `c "message"` - Quick git commit
- `mrco` - Checkout GitLab merge request using fzf

### Tool Preferences

- `fd` over `find` for directory searches
- `rg` (ripgrep) for content searches
- `eza` for enhanced directory listings
- `batcat` for file previewing
- `@antfu/ni` aliases: `ni` (install), `nr` (run script), `nun` (uninstall)

### Alias Conventions

Prefixes in `aliases`:
- `e*` - Editor shortcuts (evimrc, ezsh, ealias, efunc)
- `n*` - npm/node shortcuts (nb=build, nd=dev, nt=test, nv=verify)
- `g*` - Git shortcuts (ga=add, gco=switch, gd=diff, gl=log, etc.)
- Navigation: `..`, `...`, `repo` (~/code), `dotf` (~/dotfiles), `iad` (~/ia notes)

## Development Workflow

### For JavaScript/TypeScript Projects
- `nr build` - Run build script
- `nr test` - Run tests
- `nr verify` - Run verification (lint + typecheck + test)
- `nr typecheck` - Type checking
- `nr lint:fix` - Fix linting issues

### For This Repository
- **Installation**: Run `install.sh` to bootstrap environment and create symlinks
- **Symlinks only**: Run `symlinks.sh` to update symlinks without full install
- **Editing**: Edit files in dotfiles directory (not symlinked locations)
  - Use editor aliases: `ezsh`, `ealias`, `efunc`, `eterm`
  - Changes take effect on new shell or after `source ~/dotfiles/zshrc`
- **Scripts**: Place in appropriate `scripts/<category>/` subdirectory
  - Make executable: `chmod +x script.sh`
  - Use `#!/usr/bin/env zsh` or `#!/usr/bin/env bash` shebangs
  - Scripts with `.sh`, `.ts`, `.js` extensions are auto-symlinked to `~/bin`

## Key Dependencies

Zsh (with antidote plugin manager), Kitty terminal, Neovim, fzf, ripgrep, fd, eza, zoxide, atuin, Deno
