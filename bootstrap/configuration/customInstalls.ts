import type { Config } from "../deps.ts";

export const gnomeShellExtensionInstaller = {
  gnomeShellExtensionInstaller: {},
};

const googleChromeAmd64 = "google-chrome-stable_current_amd64.deb";
export const googleChrome = {
  debianPackage: {
    name: "google-chrome",
    url: `https://dl.google.com/linux/direct/${googleChromeAmd64}`,
  },
};

export const antidote = {
  gitClone: {
    url: "https://github.com/mattmc3/antidote.git",
    target: "~/opt/antidote/",
  },
};

const webi = {
  urlScript: {
    name: "webi",
    url: "https://webinstall.dev/webi",
  },
};

const volta = {
  urlScript: {
    name: "volta",
    url: "https://get.volta.sh",
  },
};

const brew = {
  inlineScript: {
    name: "brew",
    testScript: `which brew`,
    setScript: `
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
      test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
      test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
      echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
    `,
  },
};

export const aptUpdate = {
  aptUpdate: {},
};

const brewPackages = [
  "delta",
  "docker",
  "docker-compose",
  "fzf",
  "gh",
  "neovim",
  "potrace",
  "rg",
  "sd",
  "zoxide",
];

const voltaPackages = [
  "browser-sync",
  "ddg",
  "degit",
  "dploy",
  "eslint",
  "eslint_d",
  "firebase",
  "git-standup",
  "hygen",
  "json",
  "luafmt",
  "netlify",
  "node",
  "npm-why",
  "nx",
  "open-cli",
  "pnpm",
  "pollinate",
  "prettier",
  "prettierd",
  "stylelint",
  "tsserver",
  "typescript-language-server",
];

export const customInstalls: Config[] = [
  // preparation
  aptUpdate,
  // installers
  gnomeShellExtensionInstaller,
  webi,
  brew,
  volta,
  antidote,
  // custom applications
  googleChrome,
  ...brewPackages.map((name) => ({ brew: { name, dependsOn: brew } })),
  ...voltaPackages.map((name) => ({ volta: { name, dependsOn: volta } })),
];
