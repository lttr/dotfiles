import { Config } from '../deps.ts'
import { directoriesConfig } from './directories.ts'
import { gnomeSettingsConfig } from './gnomeSettings.ts'
import { loginShellConfig } from './loginShell.ts'
import { symlinksConfig } from './symlinks.ts'
import { customInstallsConfig } from './customInstalls.ts'

export const config: Array<Config> = [
  ...directoriesConfig,
  ...gnomeSettingsConfig,
  ...loginShellConfig,
  ...symlinksConfig,
  ...customInstallsConfig,
]
