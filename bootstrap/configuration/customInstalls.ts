import { HOME } from "../constants.ts";
import type { Config } from "../deps.ts";

export const antidote: Config = {
  gitClone: {
    url: "https://github.com/mattmc3/antidote.git",
    target: `${HOME}/opt/antidote/`,
  },
};

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
      'eval "$(~/.local/share/fnm/fnm env)" && ~/.local/share/fnm/fnm current | grep 18',
    setScript:
      'eval "$(~/.local/share/fnm/fnm env)" && ~/.local/share/fnm/fnm install 18',
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
      "mkdir -p ~/.local/bin %% ln -s ~/.local/share/pnpm/pnpm ~/.local/bin/",
  },
};

export const aptUpdate: Config = {
  aptUpdate: {},
};

const brewPackages = [
  "delta",
  "docker",
  "docker-compose",
  "fzf",
  "gh",
  "potrace",
  "rg",
  "sd",
  "zoxide",
];

const neovim: Config = {
  brew: {
    name: "nvim",
    head: true,
    dependsOn: brew,
  },
};

const pnpmPackages = [
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
  fnm,
  // gnomeShellExtensionInstaller,
  googleChrome,
  kitty,
  neovim,
  pnpm,
  node,
  ...brewPackages.map((name) => ({
    brew: { name, dependsOn: brew },
  })),
  ...pnpmPackages.map((pnpmConfig) => {
    return {
      pnpmGlobalInstall: { ...pnpmConfig, dependsOn: pnpm },
    };
  }),
];
