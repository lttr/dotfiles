import { BIN_DIR, DOTFILES, HOME, SCRIPTS } from "../constants.ts";
import { Config, fs, path } from "../deps.ts";
import { binDirectory } from "./directories.ts";

async function getExecutableScriptsConfig(dir: string): Promise<Config[]> {
  const config: Config[] = [];
  for await (
    const entry of fs.walk(dir, {
      exts: ["sh", "ts", "js"],
      includeDirs: false,
    })
  ) {
    const scriptNameWithoutExtension = path.parse(entry.path).name;
    const dest = path.join(BIN_DIR, scriptNameWithoutExtension);
    config.push({
      symlink: {
        dest,
        src: entry.path,
        dependsOn: binDirectory,
      },
    });
  }
  return config;
}

const executableScripts: Config[] = await getExecutableScriptsConfig(SCRIPTS);

export const symlinks: Config[] = [
  {
    symlink: {
      dest: path.join(HOME, ".config/kitty/kitty.conf"),
      src: path.join(DOTFILES, "kitty.conf"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/ranger/commands.py"),
      src: path.join(DOTFILES, "ranger/commands.py"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/ranger/rc.conf"),
      src: path.join(DOTFILES, "ranger/rc.conf"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/ranger/rifle.conf"),
      src: path.join(DOTFILES, "ranger/rifle.conf"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/ranger/scope.sh"),
      src: path.join(DOTFILES, "ranger/scope.sh"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".gitconfig"),
      src: path.join(DOTFILES, "gitconfig"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/nvim/init.lua"),
      src: path.join(DOTFILES, "nvim/init.lua"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/nvim/lua"),
      src: path.join(DOTFILES, "nvim/lua"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/nvim/after"),
      src: path.join(DOTFILES, "nvim/after"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".config/nvim/plugin/plugins"),
      src: path.join(DOTFILES, "nvim/plugin"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".zshenv"),
      src: path.join(DOTFILES, "zshenv"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".zshrc"),
      src: path.join(DOTFILES, "zshrc"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, ".zsh_plugins.txt"),
      src: path.join(DOTFILES, "zsh_plugins.txt"),
    },
  },
  {
    symlink: {
      dest: path.join(HOME, "bin/fd"),
      src: "/usr/bin/fdfind",
    },
  },
  ...executableScripts,
];
