import { Configuration } from '../deps.ts'
import { directoriesConfig } from './directories.ts'
import { loginShellConfig } from './loginShell.ts'
import { symlinksConfig } from './symlinks.ts'

export const config: Array<Configuration> = [
  ...symlinksConfig,
  ...directoriesConfig,
  ...loginShellConfig,
]
