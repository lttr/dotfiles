import { OPT_DIR } from '../constants.ts'
import { Config } from '../deps.ts'

export const gnomeShellExtensionInstaller = {
  gnomeShellExtensionInstaller: {
    location: OPT_DIR,
  },
}

export const googleChrome = {
  googleChrome: {},
}

export const customInstallsConfig: Config[] = [
  gnomeShellExtensionInstaller,
  googleChrome,
]
