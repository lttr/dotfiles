import { Config } from '../deps.ts'

export const gnomeShellExtensionInstaller = {
  gnomeShellExtensionInstaller: {},
}

const googleChromeAmd64 = 'google-chrome-stable_current_amd64.deb'
export const googleChrome = {
  debianPackage: {
    name: 'google-chrome',
    url: `https://dl.google.com/linux/direct/${googleChromeAmd64}`,
  },
}

const webi = {
  urlScript: {
    name: 'webi',
    url: 'https://webinstall.dev/webi',
  },
}

const brew = {
  urlScript: {
    name: 'brew',
    url: 'https://raw.githubusercontent.com/Homebrew/install/master/install.sh',
  },
}

export const antibody = {
  brew: {
    name: 'antibody',
    dependsOn: brew,
  },
}

export const customInstalls: Config[] = [
  // installers
  gnomeShellExtensionInstaller,
  webi,
  brew,
  // custom applications
  googleChrome,
  { webInstall: { name: 'rg', dependsOn: webi } },
  { brew: { name: 'gh', dependsOn: brew } },
  { brew: { name: 'fzf', dependsOn: brew } },
  { brew: { name: 'potrace', dependsOn: brew } },
  antibody,
]
