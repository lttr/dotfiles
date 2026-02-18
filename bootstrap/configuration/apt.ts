import type { Config } from "../deps.ts";

export const aptUpdate: Config = {
  aptUpdate: {},
};

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
export const gnupg2 = aptPackage("gnupg2");

export const apt: Config[] = [
  // commandline apps

  aptPackage("bat"),
  aptPackage("composer"),
  aptPackage("dict"),
  aptPackage("dict-freedict-ces-eng"),
  aptPackage("dict-freedict-eng-ces"),
  aptPackage("dict-gcide"),
  aptPackage("duf"),
  aptPackage("exiftool"),
  aptPackage("fd-find"),
  aptPackage("libheif-examples"), // provides heif-convert for HEIC images
  gnupg2,
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
  aptPackage("network-manager-openconnect-gnome"),
  aptPackage("openconnect"),
  aptPackage("wmctrl"),
];
