import { HOME } from '../constants.ts'
import { path, DirectoryConfiguration, Directory } from '../deps.ts'

export const binDirectory: DirectoryConfiguration = {
  resource: Directory,
  path: path.join(HOME, 'bin'),
} as DirectoryConfiguration

export const directoriesConfig = [
  // Make useful directories inside home
  binDirectory,
  { resource: Directory, path: path.join(HOME, 'opt') },
  { resource: Directory, path: path.join(HOME, 'code') },
  { resource: Directory, path: path.join(HOME, 'sandbox') },
  // Prepare dirs for vim
  { resource: Directory, path: path.join(HOME, '.vim') },
  { resource: Directory, path: path.join(HOME, '.vim/backups') },
  { resource: Directory, path: path.join(HOME, '.vim/undos') },
  // Prepare dirs for zsh
  { resource: Directory, path: path.join(HOME, '.zsh/completion') },
] as DirectoryConfiguration[]
