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
export const gthumb = aptPackage("gthumb");

export const apt: Config[] = [
  // commandline apps

  aptPackage("bat"),
  aptPackage("composer"),
  aptPackage("dict"),
  aptPackage("dict-freedict-ces-eng"),
  aptPackage("dict-freedict-eng-ces"),
  aptPackage("dict-gcide"),
  aptPackage("duf"),
  aptPackage("golang"),
  aptPackage("htop"),
  aptPackage("jq"),
  aptPackage("locate"),
  aptPackage("moreutils"),
  aptPackage("pandoc"),
  aptPackage("php"),
  aptPackage("ranger"),
  aptPackage("trash-cli"),
  aptPackage("tree"),
  aptPackage("unrar"),
  aptPackage("vlc"),
  aptPackage("xbindkeys"),
  aptPackage("xdotool"),
  aptPackage("xsel"),
  zsh,

  // graphical apps

  aptPackage("dconf-editor"),
  aptPackage("gnome-tweaks"),
  aptPackage("gpick"),
  gthumb,
  aptPackage("nautilus-dropbox"),
  aptPackage("wmctrl"),
];
