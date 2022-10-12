import type { Config } from "../deps.ts";
import { aptUpdate } from "./customInstalls.ts";

function aptPackage(packageName: string) {
  return {
    aptInstall: {
      packageName,
      dependsOn: aptUpdate,
    },
  };
}

export const zsh = aptPackage("zsh");

export const apt: Config[] = [
  // commandline apps

  aptPackage("dict"),
  aptPackage("dict-freedict-ces-eng"),
  aptPackage("dict-freedict-eng-ces"),
  aptPackage("dict-gcide"),
  aptPackage("duf"),
  aptPackage("htop"),
  aptPackage("httpie"),
  aptPackage("jq"),
  aptPackage("moreutils"),
  aptPackage("neovim"),
  aptPackage("pandoc"),
  aptPackage("ranger"),
  aptPackage("trash-cli"),
  aptPackage("tree"),
  aptPackage("unrar"),
  aptPackage("xbindkeys"),
  aptPackage("xdotool"),
  aptPackage("xsel"),
  zsh,

  // graphical apps

  aptPackage("dconf-editor"),
  aptPackage("gnome-tweak-tool"),
  aptPackage("gpick"),
  aptPackage("gthumb"),
  aptPackage("nautilus-dropbox"),
  aptPackage("wmctrl"),
];
