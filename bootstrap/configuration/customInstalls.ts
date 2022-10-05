import { Config } from "../deps.ts";

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

const webi = {
  urlScript: {
    name: "webi",
    url: "https://webinstall.dev/webi",
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

export const antibody = {
  brew: {
    name: "antibody",
    dependsOn: brew,
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
  antibody,
  // custom applications
  googleChrome,
  { webInstall: { name: "node", dependsOn: webi } },
  { webInstall: { name: "rg", dependsOn: webi } },
  { brew: { name: "antidote", dependsOn: brew } },
  { brew: { name: "delta", dependsOn: brew } },
  { brew: { name: "docker", dependsOn: brew } },
  { brew: { name: "docker-compose", dependsOn: brew } },
  { brew: { name: "fzf", dependsOn: brew } },
  { brew: { name: "gh", dependsOn: brew } },
  { brew: { name: "neovim", dependsOn: brew } },
  { brew: { name: "potrace", dependsOn: brew } },
  { brew: { name: "sd", dependsOn: brew } },
  { brew: { name: "zoxide", dependsOn: brew } },
];
