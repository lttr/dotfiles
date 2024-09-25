import { HOME } from "../constants.ts";
import type { Config } from "../deps.ts";

// export const gnomeShellExtensionInstaller = {
//   gnomeShellExtensionInstaller: {},
// };

const googleChromeAmd64 = "google-chrome-stable_current_amd64.deb";
export const googleChrome: Config = {
  debianPackage: {
    name: "google-chrome",
    url: `https://dl.google.com/linux/direct/${googleChromeAmd64}`,
  },
};

export const fnm: Config = {
  urlScript: {
    name: "fnm",
    url: "https://fnm.vercel.app/install",
  },
};

export const node: Config = {
  inlineScript: {
    name: "node",
    testScript:
      'eval "$(~/.local/share/fnm/fnm env)" && ~/.local/share/fnm/fnm current | grep 20',
    setScript:
      'eval "$(~/.local/share/fnm/fnm env)" && ~/.local/share/fnm/fnm install 20',
  },
  dependsOn: fnm,
};

const brew: Config = {
  urlScript: {
    name: "brew",
    url: "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh",
    postInstall:
      "mkdir -p ~/.local/bin && ln -s /home/linuxbrew/.linuxbrew/bin/brew ~/.local/bin/",
  },
};

const exp: Config = {
  inlineScript: {
    name: "exp",
    testScript: "test -f ~/opt/exp",
    setScript:
      "curl https://raw.githubusercontent.com/troydm/exp/master/exp -o ~/opt/exp && chmod +x ~/opt/exp",
  },
};

const kitty: Config = {
  urlScript: {
    name: "kitty",
    url: "https://sw.kovidgoyal.net/kitty/installer.sh",
    postInstall: `
      mkdir -p ~/.local/bin
      # Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in your system-wide PATH)
      ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
      # Place the kitty.desktop file somewhere it can be found by the OS
      cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
      # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
      cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
      # Update the paths to the kitty and its icon in the kitty.desktop file(s)
      sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
      sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
    `,
  },
};

const pnpm: Config = {
  urlScript: {
    name: "pnpm",
    url: "https://get.pnpm.io/install.sh",
    postInstall:
      "mkdir -p ~/.local/bin && ln -s ~/.local/share/pnpm/pnpm ~/.local/bin/",
  },
};

export const aptUpdate: Config = {
  aptUpdate: {},
};

const brewPackages = [
  { name: "antidote" },
  { name: "git-delta", executable: "delta" },
  { name: "docker" },
  { name: "docker-compose" },
  { name: "gh" },
  { name: "glab" },
  { name: "httpie" },
  { name: "potrace" },
  { name: "rg" },
  { name: "sd" },
  { name: "unison" },
  { name: "zoxide" },
];

export const neovim: Config = {
  brew: {
    name: "nvim",
    dependsOn: brew,
  },
};

const neovimDeps: Config = {
  inlineScript: {
    name: "NeovimDependencies",
    testScript: `ls ~/.local/share/nvim/site 2>&1 >/dev/null`,
    setScript:
      `nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'`,
    dependsOn: neovim,
  },
};

const fzf: Config = {
  brew: {
    name: "fzf",
    dependsOn: brew,
  },
};

const fzfSetup: Config = {
  inlineScript: {
    name: "fzfSetup",
    testScript: `ls "${HOME}/.fzf.zsh" 2>&1 >/dev/null`,
    setScript: `
      $(brew --prefix)/opt/fzf/install --no-update-rc
    `,
    dependsOn: fzf,
  },
};

const nerdFont: Config = {
  inlineScript: {
    name: "FiraMonoFont",
    testScript:
      `ls "${HOME}/.fonts/FiraMonoNerdFontMono-Regular.otf" 2>&1 >/dev/null`,
    setScript: `
      FONT_FILE_NAME="FiraMonoNerdFontMono-Regular.otf"
      FONT_TARGET_DIR="${HOME}/.fonts/"
      cd ~/Downloads
      curl -fsLo "$FONT_FILE_NAME" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Regular/FiraMonoNerdFontMono-Regular.otf
      mkdir -p "$FONT_TARGET_DIR"
      mv "$FONT_FILE_NAME" "$FONT_TARGET_DIR"
      fc-cache -f
      `,
  },
};

export const cursors: Config = {
  inlineScript: {
    name: "cursors",
    testScript: `ls "/usr/share/icons/BreezeX-Dark/" 2>&1 >/dev/null`,
    setScript: `
      CURSORS_FILE_NAME="BreezeX-Dark.tar.gz"
      CURSORS_TARGET_DIR="/usr/share/icons/"
      cd ~/Downloads
      curl -fsLo "$CURSORS_FILE_NAME" https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.0/BreezeX-Dark.tar.gz
      tar -xvf "$CURSORS_FILE_NAME"
      sudo mv BreezeX-Dark/ "$CURSORS_TARGET_DIR"
    `,
  },
};

const pnpmPackages = [
  { name: "@antfu/ni", executable: "ni" },
  { name: "browser-sync" },
  { name: "degit" },
  { name: "eslint" },
  { name: "eslint_d" },
  { name: "firebase-tools", executable: "firebase" },
  { name: "git-standup" },
  { name: "hygen" },
  { name: "json" },
  { name: "netlify-cli", executable: "netlify" },
  { name: "npm-why" },
  { name: "nx" },
  { name: "open-cli" },
  { name: "pollinate" },
  { name: "prettier" },
  { name: "@fsouza/prettierd", executable: "prettierd" },
  { name: "stylelint" },
  { name: "typescript-language-server" },
];

export const customInstalls: Config[] = [
  antidote,
  aptUpdate,
  brew,
  exp,
  fnm,
  // gnomeShellExtensionInstaller,
  googleChrome,
  kitty,
  neovim,
  neovimDeps,
  pnpm,
  node,
  nerdFont,
  cursors,
  fzf,
  fzfSetup,
  ...brewPackages.map((brewConfig) => ({
    brew: { ...brewConfig, dependsOn: brew },
  })),
  ...pnpmPackages.map((pnpmConfig) => {
    return {
      pnpmGlobalInstall: { ...pnpmConfig, dependsOn: pnpm },
    };
  }),
];
