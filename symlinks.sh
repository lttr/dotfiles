#!/usr/bin/env bash

cd $HOME/dotfiles/bootstrap/
$HOME/.deno/bin/deno task run --filter symlink
