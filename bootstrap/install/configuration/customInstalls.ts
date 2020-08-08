import { Config } from '../deps.ts'

// TODO this is a little bit wierd:
// It has to be installed with special resource
// and than symlinked to bin directory in order to
// make it executable
export const gnomeShellExtensionInstallerConfig = {
  gnomeShellExtensionInstaller: {
    location: '/home/lukas/opt',
  },
}

export const customInstallsConfig: Config[] = [
  gnomeShellExtensionInstallerConfig,
]
