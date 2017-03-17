#!/usr/bin/env bash

vim-packs-process() {
    vim +PlugClean +PlugInstall +PlugUpdate +qall
}
