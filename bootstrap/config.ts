import type { Config } from "./deps.ts";
import { appForMimeTypes } from "./configuration/appForMimeTypes.ts";
import { apt } from "./configuration/apt.ts";
import { customInstalls } from "./configuration/customInstalls.ts";
import { directories } from "./configuration/directories.ts";
import { flatpak } from "./configuration/flatpak.ts";
import { gnomeKeybindings } from "./configuration/gnomeKeybindings.ts";
import { gnomeSettings } from "./configuration/gnomeSettings.ts";
import { gnomeShellExtensions } from "./configuration/gnomeShellExtensions.ts";
import { shell } from "./configuration/shell.ts";
import { symlinks } from "./configuration/symlinks.ts";

export const config: Array<Config> = [
  ...apt,
  ...appForMimeTypes,
  ...customInstalls,
  ...directories,
  ...flatpak,
  ...gnomeKeybindings,
  ...gnomeSettings,
  ...gnomeShellExtensions,
  ...shell,
  ...symlinks,
];
