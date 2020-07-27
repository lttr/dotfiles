import { Config } from '../deps.ts'
import { gnomeShellExtensionInstallerSymlink } from './symlinks.ts'

export const arcMenu = {
  gnomeShellExtension: {
    fullName: 'arc-menu@linxgem33.com',
    id: 1228,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

export const userTheme = {
  gnomeShellExtension: {
    fullName: 'user-theme@gnome-shell-extensions.gcampax.github.com',
    id: 19,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

export const dashToPanel = {
  gnomeShellExtension: {
    fullName: 'dash-to-panel@jderose9.github.com',
    id: 1160,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

export const gnomeShellExtensionsConfig: Config[] = [
  arcMenu,
  dashToPanel,
  {
    gnomeShellExtension: {
      fullName: 'gsconnect@andyholmes.github.io',
      id: 1319,
      dependsOn: gnomeShellExtensionInstallerSymlink,
    },
  },
  {
    gnomeShellExtension: {
      fullName: 'pomodoro@arun.codito.in',
      id: 53,
      dependsOn: gnomeShellExtensionInstallerSymlink,
    },
  },
  userTheme,
]
