import type { Config } from "../deps.ts";

function flatpakApp(appId: string): Config {
  return {
    flatpak: {
      appId,
    },
  };
}

export const flatpak: Config[] = [
  flatpakApp("app.zen_browser.zen"),
  flatpakApp("com.obsproject.Studio"),
  flatpakApp("com.slack.Slack"),
  flatpakApp("com.spotify.Client"),
  flatpakApp("com.synology.SynologyDrive"),
  flatpakApp("org.darktable.Darktable"),
  flatpakApp("org.gnome.Epiphany"),
  flatpakApp("org.kde.kdenlive"),
  flatpakApp("org.ksnip.ksnip"),
  flatpakApp("org.remmina.Remmina"),
];
