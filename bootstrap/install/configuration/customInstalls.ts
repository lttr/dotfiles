import { OPT_DIR } from '../constants.ts'
import { Config } from '../deps.ts'

export const gnomeShellExtensionInstaller = {
  gnomeShellExtensionInstaller: {
    location: OPT_DIR,
  },
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
  webInstall: {
    name: 'brew',
    dependsOn: webi,
  },
}

export const customInstalls: Config[] = [
  gnomeShellExtensionInstaller,
  googleChrome,
  webi,
  {
    webInstall: {
      name: 'rg',
      dependsOn: webi,
    },
  },
  brew,
  {
    brew: {
      name: 'gh',
    },
  },
]
