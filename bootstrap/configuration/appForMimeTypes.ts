import { Config } from "../deps.ts";
import { gthumb } from "./apt.ts";
// import { neovim } from "./customInstalls.ts";

const defaultBrowser = "firefox";

export const appForMimeTypes: Config[] = [
  {
    appForMimeType: {
      app: `${defaultBrowser}.desktop`,
      mimeType: "text/html",
    },
  },
  {
    appForMimeType: {
      app: `${defaultBrowser}.desktop`,
      mimeType: "x-scheme-handler/http",
    },
  },
  {
    appForMimeType: {
      app: `${defaultBrowser}.desktop`,
      mimeType: "x-scheme-handler/https",
    },
  },
  {
    appForMimeType: {
      app: `${defaultBrowser}.desktop`,
      mimeType: "x-scheme-handler/about",
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/bpm",
      dependsOn: gthumb,
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/gif",
      dependsOn: gthumb,
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/ico",
      dependsOn: gthumb,
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/jpeg",
      dependsOn: gthumb,
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/jpg",
      dependsOn: gthumb,
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/png",
      dependsOn: gthumb,
    },
  },
  {
    appForMimeType: {
      app: "org.gnome.gThumb.desktop",
      mimeType: "image/tiff",
      dependsOn: gthumb,
    },
  },
  // {
  //   appForMimeType: {
  //     app: "nvim.desktop",
  //     mimeType: "text/plain",
  //     dependsOn: neovim,
  //   },
  // },
  // {
  //   appForMimeType: {
  //     app: "nvim.desktop",
  //     mimeType: "application/x-mswinurl",
  //     dependsOn: neovim,
  //   },
  // },
  // {
  //   appForMimeType: {
  //     app: "nvim.desktop",
  //     mimeType: "text/markdown",
  //     dependsOn: neovim,
  //   },
  // },
  // {
  //   appForMimeType: {
  //     app: "nvim.desktop",
  //     mimeType: "text/x-log",
  //     dependsOn: neovim,
  //   },
  // },
];
