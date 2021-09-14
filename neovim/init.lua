local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt


-- Make sure packer is installed
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerCompile
  augroup end
]])

-- packages
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-commentary'
  use 'vim-scripts/loremipsum'
  use {'neoclide/coc.nvim', branch = 'master', run = 'yarn install --frozen-lockfile'}
end)

-- options
opt.expandtab = true
opt.number = true

-- keyboard
g.mapleader = ","
