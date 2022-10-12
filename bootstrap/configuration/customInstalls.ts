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
  { webInstall: { name: "node", dependsOn: webi } },
  { webInstall: { name: "rg", dependsOn: webi } },
  { brew: { name: "delta", dependsOn: brew } },
  { brew: { name: "docker", dependsOn: brew } },
  { brew: { name: "docker-compose", dependsOn: brew } },
  { brew: { name: "fzf", dependsOn: brew } },
  { brew: { name: "gh", dependsOn: brew } },
  { brew: { name: "neovim", dependsOn: brew } },
  { brew: { name: "potrace", dependsOn: brew } },
  { brew: { name: "sd", dependsOn: brew } },
  { brew: { name: "zoxide", dependsOn: brew } },
  { volta: { name: "prettierd", dependsOn: volta } },
  { volta: { name: "browser-sync", dependsOn: volta } },
  { volta: { name: "ddg", dependsOn: volta } },
  { volta: { name: "degit", dependsOn: volta } },
  { volta: { name: "dploy", dependsOn: volta } },
  { volta: { name: "eslint", dependsOn: volta } },
  { volta: { name: "eslint_d", dependsOn: volta } },
  { volta: { name: "firebase", dependsOn: volta } },
  { volta: { name: "git-standup", dependsOn: volta } },
  { volta: { name: "hygen", dependsOn: volta } },
  { volta: { name: "json", dependsOn: volta } },
  { volta: { name: "luafmt", dependsOn: volta } },
  { volta: { name: "netlify", dependsOn: volta } },
  { volta: { name: "npm-why", dependsOn: volta } },
  { volta: { name: "nx", dependsOn: volta } },
  { volta: { name: "open-cli", dependsOn: volta } },
  { volta: { name: "pnpm", dependsOn: volta } },
  { volta: { name: "pollinate", dependsOn: volta } },
  { volta: { name: "prettier", dependsOn: volta } },
  { volta: { name: "stylelint", dependsOn: volta } },
  { volta: { name: "tsserver", dependsOn: volta } },
  { volta: { name: "typescript-language-server", dependsOn: volta } },
];
