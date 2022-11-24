import { Config } from "../deps.ts";
import { gnomeShellExtensionInstaller } from "./customInstalls.ts";

// const EMPTY_ARRAY = "@as []";

// const arcMenu = {
//   gnomeShellExtension: {
//     fullName: 'arc-menu@linxgem33.com',
//     id: 1228,
//     dependsOn: gnomeShellExtensionInstaller,
//   },
// }

// const arcMenuSettings = [
//   {
//     gnomeSettings: {
//       schema: 'org.gnome.shell.extensions.arc-menu',
//       key: 'menu-layout',
//       value: 'Runner',
//       dependsOn: arcMenu,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: 'org.gnome.shell.extensions.arc-menu',
//       key: 'position-in-panel',
//       value: 'Left',
//       dependsOn: arcMenu,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: 'org.gnome.shell.extensions.arc-menu',
//       key: 'menu-hotkey',
//       value: 'Super_L',
//       dependsOn: arcMenu,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: 'org.gnome.shell.extensions.arc-menu',
//       key: 'menu-button-icon',
//       value: 'System_Icon',
//       dependsOn: arcMenu,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: 'org.gnome.shell.extensions.arc-menu',
//       key: 'runner-position',
//       value: 'Centered',
//       dependsOn: arcMenu,
//     },
//   },
// ]

// const clockOverride = {
//   gnomeShellExtension: {
//     fullName: "clock-override@gnomeshell.kryogenix.org",
//     id: 1206,
//     dependsOn: gnomeShellExtensionInstaller,
//   },
// };

// const clockOverrideSettings = [
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.clock-override",
//       key: "override-string",
//       value: "%H:%M",
//       dependsOn: clockOverride,
//     },
//   },
// ];

// const userTheme = {
//   gnomeShellExtension: {
//     fullName: "user-theme@gnome-shell-extensions.gcampax.github.com",
//     id: 19,
//     dependsOn: gnomeShellExtensionInstaller,
//   },
// };

// const userThemeSettings = [
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.user-theme",
//       key: "name",
//       value: "Pop-dark",
//       dependsOn: userTheme,
//     },
//   },
// ];

const dashToPanel = {
  gnomeShellExtension: {
    fullName: "dash-to-panel@jderose9.github.com",
    id: 1160,
    dependsOn: gnomeShellExtensionInstaller,
  },
};

const dashToPanelRawSettings = [
  ["appicon-margin", 4],
  ["appicon-padding", 6],
  ["dot-color-1", "#5294e2"],
  ["dot-color-2", "#5294e2"],
  ["dot-color-3", "#5294e2"],
  ["dot-color-4", "#5294e2"],
  ["dot-color-dominant", true],
  ["dot-color-override", false],
  ["dot-color-unfocused-1", "#5294e2"],
  ["dot-color-unfocused-2", "#5294e2"],
  ["dot-color-unfocused-3", "#5294e2"],
  ["dot-color-unfocused-4", "#5294e2"],
  ["dot-position", "BOTTOM"],
  ["dot-size", 1],
  ["dot-style-focused", "SEGMENTED"],
  ["dot-style-unfocused", "SEGMENTED"],
  ["focus-highlight-color", "#eeeeec"],
  ["force-check-update", false],
  ["group-apps", false],
  ["group-apps-label-font-color", "#d3d7cf"],
  ["group-apps-label-font-color-minimized", "#888a85"],
  ["group-apps-label-font-size", 12],
  ["group-apps-label-font-weight", "lighter"],
  ["group-apps-label-max-width", 40],
  ["group-apps-underline-unfocused", true],
  ["group-apps-use-fixed-width", true],
  ["group-apps-use-launchers", false],
  ["hot-keys", true],
  ["hotkeys-overlay-combo", "TEMPORARILY"],
  ["isolate-workspaces", true],
  ["leftbox-padding", -1],
  ["leftbox-size", 0],
  ["middle-click-action", "LAUNCH"],
  ["multi-monitors", false],
  ["overlay-timeout", 500],
  ["panel-size", 30],
  ["scroll-icon-action", "NOTHING"],
  ["scroll-panel-action", "NOTHING"],
  ["shift-click-action", "LAUNCH"],
  ["shift-middle-click-action", "LAUNCH"],
  ["shortcut-previews", true],
  ["show-activities-button", false],
  ["show-appmenu", false],
  ["show-apps-icon-file", ""],
  ["show-favorites", true],
  ["show-tooltip", false],
  ["show-window-previews", false],
  ["show-window-previews-timeout", 800],
  ["status-icon-padding", -1],
  ["stockgs-keep-dash", false],
  ["taskbar-locked", true],
  ["trans-panel-opacity", 0.90000000000000002],
  ["trans-use-custom-bg", false],
  ["trans-use-custom-gradient", false],
  ["trans-use-custom-opacity", false],
  ["trans-use-dynamic-opacity", false],
  ["tray-padding", 12],
  ["tray-size", 14],
];

const dashToPanelSettings = dashToPanelRawSettings.map((item) => {
  const [key, value] = item;
  return {
    gnomeSettings: {
      schemadir:
        "~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas",
      schema: "org.gnome.shell.extensions.dash-to-panel",
      key: key as string,
      value,
      dependsOn: dashToPanel,
    },
  };
});

const gsconnect = {
  gnomeShellExtension: {
    fullName: "gsconnect@andyholmes.github.io",
    id: 1319,
    dependsOn: gnomeShellExtensionInstaller,
  },
};

// const pomodoro = {
//   gnomeShellExtension: {
//     fullName: "pomodoro@arun.codito.in",
//     id: 53,
//     dependsOn: gnomeShellExtensionInstaller,
//   },
// };

// const workspaceSwitcherDestination =
//   "~/.local/share/gnome-shell/extensions/workspace-switcher@tomha.github.com";
// const workspaceSwitcherGit =
//   "https://github.com/tomha/gnome-shell-extension-workspace-switcher";
// const workspaceSwitcher = {
//   inlineScript: {
//     name: "install gnome extension Workspace switcher",
//     testScript: `
//       gsettings list-keys org.gnome.shell.extensions.workspace-switcher &>/dev/null
//     `,
//     setScript: `
//       git clone --quiet ${workspaceSwitcherGit} ${workspaceSwitcherDestination}
//       && sudo cp ~/.local/share/gnome-shell/extensions/workspace-switcher@tomha.github.com/schema/org.gnome.shell.extensions.workspace-switcher.gschema.xml /usr/share/glib-2.0/schemas/
//       && sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
//     `,
//   },
// };

// const workspaceSwitcherSettings = [
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.workspace-switcher",
//       key: "background-colour-active",
//       value: "#555753ff",
//       depdendsOn: workspaceSwitcher,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.workspace-switcher",
//       key: "border-locations",
//       value: EMPTY_ARRAY,
//       depdendsOn: workspaceSwitcher,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.workspace-switcher",
//       key: "font-active",
//       value: "Ubuntu Medium 11",
//       depdendsOn: workspaceSwitcher,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.workspace-switcher",
//       key: "index",
//       value: 1,
//       depdendsOn: workspaceSwitcher,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.workspace-switcher",
//       key: "position",
//       value: "LEFT",
//       depdendsOn: workspaceSwitcher,
//     },
//   },
//   {
//     gnomeSettings: {
//       schema: "org.gnome.shell.extensions.workspace-switcher",
//       key: "show-names",
//       value: false,
//       depdendsOn: workspaceSwitcher,
//     },
//   },
// ];

export const gnomeShellExtensions: Config[] = [
  // arcMenu,
  // ...arcMenuSettings,
  // clockOverride,
  // ...clockOverrideSettings,
  dashToPanel,
  ...dashToPanelSettings,
  gsconnect,
  // pomodoro,
  // userTheme,
  // ...userThemeSettings,
  // workspaceSwitcher,
  // ...workspaceSwitcherSettings,
];
