import { BIN, DOTFILES, HOME, SCRIPTS } from '../constants.ts'
import {
  fs,
  path,
  Configuration,
  SymlinkConfiguration,
  Symlink,
} from '../deps.ts'
import { binDirectory } from './directories.ts'

async function getExecutableScriptsConfig(
  dir: string
): Promise<SymlinkConfiguration[]> {
  const config: SymlinkConfiguration[] = []
  for await (const entry of fs.walk(dir, {
    exts: ['sh'],
  })) {
    const scriptNameWithoutExtension = path.parse(entry.path).name
    const dest = path.join(BIN, scriptNameWithoutExtension)
    config.push({
      resource: Symlink,
      dest,
      src: entry.path,
      dependsOn: binDirectory as Configuration,
    } as SymlinkConfiguration)
  }
  return config
}

const executableScriptsConfig = await getExecutableScriptsConfig(SCRIPTS)

export const symlinksConfig = [
  {
    resource: Symlink,
    dest: path.join(HOME, '.Xresources'),
    src: path.join(DOTFILES, 'Xresources'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.agignore'),
    src: path.join(DOTFILES, 'agignore'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/ranger/commands.py'),
    src: path.join(DOTFILES, 'ranger/commands.py'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/ranger/rc.conf'),
    src: path.join(DOTFILES, 'ranger/rc.conf'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/ranger/rifle.conf'),
    src: path.join(DOTFILES, 'ranger/rifle.conf'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/ranger/scope.sh'),
    src: path.join(DOTFILES, 'ranger/scope.sh'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/Code/User/settings.json'),
    src: path.join(DOTFILES, 'vscode/settings.json'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/Code/User/keybindings.json'),
    src: path.join(DOTFILES, 'vscode/keybindings.json'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.gitconfig'),
    src: path.join(DOTFILES, 'gitconfig'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.vimrc'),
    src: path.join(DOTFILES, 'vimrc'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.zshenv'),
    src: path.join(DOTFILES, 'zshenv'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.zshrc'),
    src: path.join(DOTFILES, 'zshrc'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.hyper.js'),
    src: path.join(DOTFILES, 'hyperterm/hyper.js'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.hyperlayout'),
    src: path.join(DOTFILES, 'hyperterm/hyperlayout'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.vim/colors'),
    src: path.join(DOTFILES, 'vim/colors'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.vim/snippets'),
    src: path.join(DOTFILES, 'vim/snippets'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.vim/syntax'),
    src: path.join(DOTFILES, 'vim/syntax'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.config/Code/User/snippets'),
    src: path.join(DOTFILES, 'vscode/snippets'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.hyper_plugins/local/hyper-solarized-light'),
    src: path.join(DOTFILES, 'hyperterm/hyper-solarized-light'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, '.hyper_plugins/local/hyper-solarized-dark'),
    src: path.join(DOTFILES, 'hyperterm/hyper-solarized-dark'),
  },
  {
    resource: Symlink,
    dest: path.join(HOME, 'bin/packs'),
    src: path.join(DOTFILES, 'packages/packs.sh'),
  },
  ...executableScriptsConfig,
] as SymlinkConfiguration[]
