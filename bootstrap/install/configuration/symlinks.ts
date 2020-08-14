import { BIN_DIR, DOTFILES, HOME, SCRIPTS } from '../constants.ts'
import { Config, fs, path } from '../deps.ts'
import { binDirectory } from './directories.ts'

async function getExecutableScriptsConfig(dir: string): Promise<Config[]> {
  const config: Config[] = []
  for await (const entry of fs.walk(dir, {
    exts: ['sh'],
  })) {
    const scriptNameWithoutExtension = path.parse(entry.path).name
    const dest = path.join(BIN_DIR, scriptNameWithoutExtension)
    config.push({
      symlink: {
        dest,
        src: entry.path,
        dependsOn: binDirectory,
      },
    })
  }
  return config
}

const executableScriptsConfig: Config[] = await getExecutableScriptsConfig(
  SCRIPTS
)

export const symlinksConfig: Config[] = [
  {
    symlink: {
      dest: path.join(HOME, '.Xresources'),
      src: path.join(DOTFILES, 'Xresources'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.agignore'),
      src: path.join(DOTFILES, 'agignore'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/ranger/commands.py'),
      src: path.join(DOTFILES, 'ranger/commands.py'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/ranger/rc.conf'),
      src: path.join(DOTFILES, 'ranger/rc.conf'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/ranger/rifle.conf'),
      src: path.join(DOTFILES, 'ranger/rifle.conf'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/ranger/scope.sh'),
      src: path.join(DOTFILES, 'ranger/scope.sh'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/Code/User/settings.json'),
      src: path.join(DOTFILES, 'vscode/settings.json'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/Code/User/keybindings.json'),
      src: path.join(DOTFILES, 'vscode/keybindings.json'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.gitconfig'),
      src: path.join(DOTFILES, 'gitconfig'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.vimrc'),
      src: path.join(DOTFILES, 'vimrc'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.zshenv'),
      src: path.join(DOTFILES, 'zshenv'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.zshrc'),
      src: path.join(DOTFILES, 'zshrc'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.hyper.js'),
      src: path.join(DOTFILES, 'hyperterm/hyper.js'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.hyperlayout'),
      src: path.join(DOTFILES, 'hyperterm/hyperlayout'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.vim/colors'),
      src: path.join(DOTFILES, 'vim/colors'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.vim/snippets'),
      src: path.join(DOTFILES, 'vim/snippets'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.vim/syntax'),
      src: path.join(DOTFILES, 'vim/syntax'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.config/Code/User/snippets'),
      src: path.join(DOTFILES, 'vscode/snippets'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.hyper_plugins/local/hyper-solarized-light'),
      src: path.join(DOTFILES, 'hyperterm/hyper-solarized-light'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, '.hyper_plugins/local/hyper-solarized-dark'),
      src: path.join(DOTFILES, 'hyperterm/hyper-solarized-dark'),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, 'bin/packs'),
      src: path.join(DOTFILES, 'packages/packs.sh'),
    },
  },
  ...executableScriptsConfig,
]
