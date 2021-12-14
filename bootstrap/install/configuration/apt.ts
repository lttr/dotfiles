import { Config } from "../deps.ts";
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

  aptPackage("alacritty"),
  // aptPackage('ansible'),
  // aptPackage('composer'),
  aptPackage("dict"),
  aptPackage("dict-freedict-ces-eng"),
  aptPackage("dict-freedict-eng-ces"),
  aptPackage("dict-gcide"),
  // aptPackage('dos2unix'),
  // aptPackage('expect'),
  // aptPackage("fasd"),
  aptPackage("htop"),
  aptPackage("httpie"),
  aptPackage("jq"),
  aptPackage("neovim"),
  // aptPackage('nmap'),
  // aptPackage('numlockx'),
  // aptPackage('openvpn'),
  aptPackage("pandoc"),
  // aptPackage('php'),
  aptPackage("ranger"),
  aptPackage("silversearcher-ag"),
  // aptPackage('snapd'),
  // aptPackage('sshpass'),
  aptPackage("tmux"),
  aptPackage("trash-cli"),
  aptPackage("tree"),
  aptPackage("unrar"),
  aptPackage("xbindkeys"),
  aptPackage("xdotool"),
  aptPackage("xsel"),
  // aptPackage('xmlstarlet'),
  zsh,

  // graphical apps

  aptPackage("dconf-editor"),
  aptPackage("dmz-cursor-theme"),
  aptPackage("doublecmd-gtk"),
  // aptPackage('gimp'),
  // aptPackage('gnome-clocks'),
  // aptPackage('gnome-shell-pomodoro'),
  aptPackage("gnome-tweak-tool"),
  aptPackage("gpick"),
  aptPackage("gthumb"),
  aptPackage("inkscape"),
  aptPackage("nautilus-dropbox"),
  // aptPackage('remmina'),
  aptPackage("vim-gtk3"),
  aptPackage("wmctrl"),
  // aptPackage('xbacklight'),
];
