const EMPTY_ARRAY = "@as []";

const customGnomeKeybindingSchemas = new Set<string>();

function customGnomeKeybinding(
  id: number,
  name: string,
  command: string,
  binding: string,
) {
  const prefix =
    `org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:`;
  let schema =
    `/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${id}/`;
  customGnomeKeybindingSchemas.add(schema);
  schema = prefix + schema;
  return [
    { gnomeSettings: { schema, key: "command", value: command } },
    { gnomeSettings: { schema, key: "name", value: name } },
    { gnomeSettings: { schema, key: "binding", value: binding } },
  ];
}

const customGnomeKeybindings = [
  ...customGnomeKeybinding(
    0,
    "Center window",
    "center-window",
    "<Primary><Super>c",
  ),
  ...customGnomeKeybinding(
    0,
    "Margin window",
    "margin-window",
    "<Primary><Super>m",
  ),
  ...customGnomeKeybinding(
    0,
    "Minimize but active",
    "minimize-but-active",
    "<Primary><Super>b",
  ),
  ...customGnomeKeybinding(0, "Sleep", "systemctl suspend", "<Super>u"),
  ...customGnomeKeybinding(
    1,
    "VPN Quanti",
    "nmcli con up id Quanti",
    "<Primary><Super>v",
  ),
];

const customGnomeKeybindingsSetup = {
  gnomeSettings: {
    schema: "org.gnome.settings-daemon.plugins.media-keys",
    key: "custom-keybindings",
    value: `[${
      Array.from(customGnomeKeybindingSchemas)
        .map((schema) => `'${schema}'`)
        .join(", ")
    }]`,
  },
};

const gnomeKeybindingsOverrrides = [
  // custom volume controls - no dependency on physical media keys
  {
    gnomeSettings: {
      schema: "org.gnome.settings-daemon.plugins.media-keys",
      key: "volume-down",
      value: "['<Super>bracketleft']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.settings-daemon.plugins.media-keys",
      key: "volume-up",
      value: "['<Super>bracketright']",
    },
  },
  // disable screensaver key
  {
    gnomeSettings: {
      schema: "org.gnome.settings-daemon.plugins.media-keys",
      key: "screensaver",
      value: EMPTY_ARRAY,
    },
  },
  // file explorer
  {
    gnomeSettings: {
      schema: "org.gnome.settings-daemon.plugins.media-keys",
      key: "home",
      value: "['<Super>e']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.settings-daemon.plugins.media-keys",
      key: "email",
      value: EMPTY_ARRAY,
    },
  },
  // gnome shell specific
  {
    gnomeSettings: {
      schema: "org.gnome.shell.keybindings",
      key: "focus-active-notification",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.keybindings",
      key: "open-application-menu",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.keybindings",
      key: "toggle-application-view",
      value: "['<Super>i']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.keybindings",
      key: "toggle-message-tray",
      value: "['<Super>n']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.keybindings",
      key: "toggle-overview",
      value: "['<Super>o']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.mutter.keybindings",
      key: "toggle-tiled-left",
      value: "['<Super>Left', '<Super>h']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.mutter.keybindings",
      key: "toggle-tiled-right",
      value: "['<Super>Right', '<Super>l']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "begin-move",
      value: "['<Super>F7']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "begin-resize",
      value: "['<Super>F8']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "close",
      value: "['<Super>x']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "cycle-group",
      value: "['<Super>Tab']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "cycle-group-backward",
      value: "['<Shift><Super>Tab']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "lower",
      value: "['<Super>z']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "maximize",
      value: "['<Super>k', '<Super>Up']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "minimize",
      value: "['<Super>b']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "move-to-center",
      value: "['<Super>c']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "move-to-monitor-left",
      value: "['<Primary><Shift><Super>Left', '<Primary><Shift><Super>h']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "move-to-monitor-right",
      value: "['<Primary><Shift><Super>Right', '<Primary><Shift><Super>l']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "move-to-workspace-down",
      value: "['<Shift><Super>Down', '<Shift><Super>j']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "move-to-workspace-up",
      value: "['<Shift><Super>Up', '<Shift><Super>k']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-to-workspace-down",
      value: "['<Primary><Super>Down', '<Primary><Super>j']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-to-workspace-last",
      value: "['<Primary><Super>End']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-to-workspace-up",
      value: "['<Primary><Super>Up', '<Primary><Super>k']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "show-desktop",
      value: "['<Shift><Super>d']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-group-backward",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-group",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-applications",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-applications-backward",
      value: "['<Shift><Super>Tab', '<Shift><Alt>Tab']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-windows",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "switch-windows-backward",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "cycle-windows",
      value: "['<Alt>Tab']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "cycle-windows-backward",
      value: "['<Shift><Alt>Tab']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "toggle-fullscreen",
      value: "['<Super>F11']",
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "toggle-maximized",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.desktop.wm.keybindings",
      key: "unmaximize",
      value: "['<Super>j', '<Super>Down']",
    },
  },
  // pop-shell
  {
    gnomeSettings: {
      schema: "org.gnome.shell.extensions.pop-shell",
      key: "focus-right",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.extensions.pop-shell",
      key: "focus-left",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.extensions.pop-shell",
      key: "focus-down",
      value: EMPTY_ARRAY,
    },
  },
  {
    gnomeSettings: {
      schema: "org.gnome.shell.extensions.pop-shell",
      key: "focus-up",
      value: EMPTY_ARRAY,
    },
  },
];

export const gnomeKeybindings = [
  customGnomeKeybindingsSetup,
  ...customGnomeKeybindings,
  ...gnomeKeybindingsOverrrides,
];
