import { Config } from '../deps.ts'
import { appForMimeTypes } from './appForMimeTypes.ts'
import { customInstallsConfig } from './customInstalls.ts'
import { directoriesConfig } from './directories.ts'
import { gnomeKeybindingsConfig } from './gnomeKeybindings.ts'
import { gnomeSettingsConfig } from './gnomeSettings.ts'
import { gnomeShellExtensionsConfig } from './gnomeShellExtensions.ts'
import { loginShellConfig } from './loginShell.ts'
import { symlinksConfig } from './symlinks.ts'
import { webInstallConfig } from './webInstall.ts'

export const config: Array<Config> = [
  ...appForMimeTypes,
  ...customInstallsConfig,
  ...directoriesConfig,
  ...gnomeKeybindingsConfig,
  ...gnomeSettingsConfig,
  ...gnomeShellExtensionsConfig,
  ...loginShellConfig,
  ...symlinksConfig,
  ...webInstallConfig,
]
