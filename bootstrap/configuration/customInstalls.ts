import { HOME } from "../constants.ts";
import type { Config } from "../deps.ts";

export const gnomeShellExtensionInstaller = {
  gnomeShellExtensionInstaller: {},
};

const googleChromeAmd64 = "google-chrome-stable_current_amd64.deb";
export const googleChrome: Config = {
  debianPackage: {
    name: "google-chrome",
    url: `https://dl.google.com/linux/direct/${googleChromeAmd64}`,
  },
};

export const antidote: Config = {
  gitClone: {
    url: "https://github.com/mattmc3/antidote.git",
    target: `${HOME}/opt/antidote/`,
  },
};

export const fnm: Config = {
  urlScript: {
    name: "fnm",
    url: "https://fnm.vercel.app/install",
    params: ["--skip-shell"],
  },
};

const deno: Config = {
  urlScript: {
    name: "deno",
    url: "https://deno.land/x/install/install.sh",
  },
};

const brew: Config = {
  urlScript: {
    name: "deno",
    url: "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh",
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

const pnpm: Config = {
  brew: {
    name: "pnpm",
    dependsOn: brew,
  },
};

const pnpmPackages = [
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
  "lua-fmt",
  "netlify",
  "npm-why",
  "nx",
  "open-cli",
  "pollinate",
  "prettier",
  "@fsouza/prettierd",
  "stylelint",
  "typescript-language-server",
];

export const customInstalls: Config[] = [
  // preparation
  aptUpdate,
  // installers
  gnomeShellExtensionInstaller,
  brew,
  antidote,
  fnm,
  pnpm,
  neovim,
  deno,
  // custom applications
  googleChrome,
  ...brewPackages.map((name) => ({
    brew: { name, dependsOn: brew },
  })),
  ...pnpmPackages.map((name) => ({
    pnpmGlobalInstall: { name, dependsOn: pnpm },
  })),
];
