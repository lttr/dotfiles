import { HOME } from '../constants.ts'
import { path, Config } from '../deps.ts'

export const binDirectory = {
  directory: { path: path.join(HOME, 'bin') },
}

export const directories: Config[] = [
  // Make useful directories inside home
  binDirectory,
  { directory: { path: path.join(HOME, 'code') } },
  { directory: { path: path.join(HOME, 'sandbox') } },
  // Prepare dirs for vim
  { directory: { path: path.join(HOME, '.vim') } },
  { directory: { path: path.join(HOME, '.vim/backups') } },
  { directory: { path: path.join(HOME, '.vim/undos') } },
  // Prepare dirs for zsh
  { directory: { path: path.join(HOME, '.zsh/completion') } },
]
