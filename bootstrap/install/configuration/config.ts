import type { Config } from "../deps.ts";
import { appForMimeTypes } from "./appForMimeTypes.ts";
import { apt } from "./apt.ts";
import { customInstalls } from "./customInstalls.ts";
import { directories } from "./directories.ts";
import { gnomeKeybindings } from "./gnomeKeybindings.ts";
import { gnomeSettings } from "./gnomeSettings.ts";
import { gnomeShellExtensions } from "./gnomeShellExtensions.ts";
import { shell } from "./shell.ts";
import { symlinks } from "./symlinks.ts";

export const config: Array<Config> = [
  ...apt,
  ...appForMimeTypes,
  ...customInstalls,
  ...directories,
  ...gnomeKeybindings,
  ...gnomeSettings,
  ...gnomeShellExtensions,
  ...shell,
  ...symlinks,
];
