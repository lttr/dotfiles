import { HOME } from "../constants.ts";
import { Config } from "../deps.ts";
// import { gnomeShellExtensionInstaller } from "./customInstalls.ts";

// const EMPTY_ARRAY = "@as []";

// const dashToPanel = {
//   gnomeShellExtension: {
//     fullName: "dash-to-panel@jderose9.github.com",
//     id: 1160,
//     dependsOn: gnomeShellExtensionInstaller,
//   },
// };

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
  [
    "panel-element-positions",
    `{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}`,
  ],
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
        `${HOME}/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas`,
      schema: "org.gnome.shell.extensions.dash-to-panel",
      key: key as string,
      value,
      // dependsOn: dashToPanel,
    },
  };
});

export const gnomeShellExtensions: Config[] = [
  // dashToPanel,
  ...dashToPanelSettings,
];
