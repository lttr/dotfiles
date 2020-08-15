import { Config } from '../deps.ts'
import { appForMimeTypes } from './appForMimeTypes.ts'
import { customInstalls } from './customInstalls.ts'
import { directories } from './directories.ts'
import { gnomeKeybindings } from './gnomeKeybindings.ts'
import { gnomeSettings } from './gnomeSettings.ts'
import { gnomeShellExtensions } from './gnomeShellExtensions.ts'
import { loginShell } from './loginShell.ts'
import { symlinks } from './symlinks.ts'

export const config: Array<Config> = [
  ...appForMimeTypes,
  ...customInstalls,
  ...directories,
  ...gnomeKeybindings,
  ...gnomeSettings,
  ...gnomeShellExtensions,
  ...loginShell,
  ...symlinks,
]
