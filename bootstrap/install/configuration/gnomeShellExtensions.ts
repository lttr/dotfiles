import { Config } from '../deps.ts'
import { gnomeShellExtensionInstallerSymlink } from './symlinks.ts'

const arcMenu = {
  gnomeShellExtension: {
    fullName: 'arc-menu@linxgem33.com',
    id: 1228,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

const arcMenuSettings = [
  {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.arc-menu',
      key: 'menu-layout',
      value: 'Runner',
      dependsOn: arcMenu,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.arc-menu',
      key: 'position-in-panel',
      value: 'Left',
      dependsOn: arcMenu,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.arc-menu',
      key: 'menu-hotkey',
      value: 'Super_L',
      dependsOn: arcMenu,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.arc-menu',
      key: 'menu-button-icon',
      value: 'System_Icon',
      dependsOn: arcMenu,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.arc-menu',
      key: 'runner-position',
      value: 'Centered',
      dependsOn: arcMenu,
    },
  },
]

const userTheme = {
  gnomeShellExtension: {
    fullName: 'user-theme@gnome-shell-extensions.gcampax.github.com',
    id: 19,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

const userThemeSettings = [
  {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.user-theme',
      key: 'name',
      value: 'Pop-dark-slim',
      dependsOn: userTheme,
    },
  },
]

const dashToPanel = {
  gnomeShellExtension: {
    fullName: 'dash-to-panel@jderose9.github.com',
    id: 1160,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

const dashToPanelRawSettings = [
  ['show-favorites', true],
  ['dot-style-unfocused', 'SEGMENTED'],
  ['tray-size', 14],
  ['show-appmenu', false],
  ['hotkeys-overlay-combo', 'TEMPORARILY'],
  ['shortcut-previews', true],
  ['dot-color-3', '#5294e2'],
  ['tray-padding', 12],
  ['status-icon-padding', -1],
  ['taskbar-locked', true],
  ['show-activities-button', false],
  ['group-apps-label-font-size', 13],
  ['scroll-panel-action', 'NOTHING'],
  ['overlay-timeout', 500],
  ['dot-color-4', '#5294e2'],
  ['shift-click-action', 'LAUNCH'],
  ['show-show-apps-button', false],
  ['location-clock', 'STATUSRIGHT'],
  ['focus-highlight-color', '#eeeeec'],
  ['dot-color-unfocused-1', '#5294e2'],
  ['dot-style-focused', 'SEGMENTED'],
  ['middle-click-action', 'LAUNCH'],
  ['dot-color-dominant', true],
  ['show-tooltip', false],
  ['show-window-previews', false],
  ['appicon-padding', 6],
  ['hot-keys', true],
  ['group-apps-label-font-color', '#dddddd'],
  ['leftbox-size', 0],
  ['dot-color-unfocused-2', '#5294e2'],
  ['trans-panel-opacity', 0.90000000000000002],
  ['group-apps-use-launchers', false],
  ['panel-size', 30],
  ['group-apps', false],
  ['dot-color-override', false],
  ['trans-use-custom-bg', false],
  ['group-apps-label-font-weight', 'lighter'],
  ['group-apps-underline-unfocused', true],
  ['scroll-icon-action', 'NOTHING'],
  ['multi-monitors', false],
  ['dot-color-unfocused-3', '#5294e2'],
  ['dot-color-1', '#5294e2'],
  ['force-check-update', false],
  ['show-window-previews-timeout', 800],
  ['group-apps-use-fixed-width', true],
  ['leftbox-padding', -1],
  ['stockgs-keep-dash', false],
  ['group-apps-label-max-width', 50],
  ['shift-middle-click-action', 'LAUNCH'],
  ['dot-size', 1],
  ['show-apps-icon-file', ''],
  ['dot-color-2', '#5294e2'],
  ['dot-color-unfocused-4', '#5294e2'],
  ['dot-position', 'BOTTOM'],
  ['appicon-margin', 4],
  ['trans-use-dynamic-opacity', false],
  ['trans-use-custom-opacity', false],
  ['show-showdesktop-button', false],
  ['trans-use-custom-gradient', false],
]

const dashToPanelSettings = dashToPanelRawSettings.map(item => {
  const [key, value] = item
  return {
    gnomeSettings: {
      schema: 'org.gnome.shell.extensions.dash-to-panel',
      key: key as string,
      value,
      dependsOn: dashToPanel,
    },
  }
})

const gsconnect = {
  gnomeShellExtension: {
    fullName: 'gsconnect@andyholmes.github.io',
    id: 1319,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

const pomodoro = {
  gnomeShellExtension: {
    fullName: 'pomodoro@arun.codito.in',
    id: 53,
    dependsOn: gnomeShellExtensionInstallerSymlink,
  },
}

export const gnomeShellExtensionsConfig: Config[] = [
  arcMenu,
  ...arcMenuSettings,
  dashToPanel,
  ...dashToPanelSettings,
  gsconnect,
  pomodoro,
  userTheme,
  ...userThemeSettings,
]
