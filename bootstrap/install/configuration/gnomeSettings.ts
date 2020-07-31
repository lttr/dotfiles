import { Config } from '../deps.ts'

export const gnomeSettingsConfig: Config[] = [
  // =================================================================
  //                          Gnome desktop
  // =================================================================

  // disable fancy gnome animations
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'enable-animations',
      value: 'false',
    },
  },

  // disable cursor blinking
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'cursor-blink',
      value: false,
    },
  },

  // clock in panel
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'clock-format',
      value: '24h',
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'clock-show-date',
      value: false,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'clock-show-seconds',
      value: false,
    },
  },

  // window buttons (pop_os has only close button by default)
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.wm.preferences',
      key: 'button-layout',
      value: 'appmenu:minimize,maximize,close',
    },
  },

  // desktop background
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.background',
      key: 'show-desktop-icons',
      value: false,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.background',
      key: 'primary-color',
      value: '#425265',
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.background',
      key: 'secondary-color',
      value: '#425265',
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.background',
      key: 'color-shading-type',
      value: 'solid',
    },
  },

  // workspaces
  {
    gnomeSettings: {
      schema: 'org.gnome.mutter',
      key: 'workspaces-only-on-primary',
      value: false,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.mutter',
      key: 'dynamic-workspaces',
      value: false,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.wm.preferences',
      key: 'num-workspaces',
      value: 2,
    },
  },

  // =================================================================
  //                             Theme
  // =================================================================

  // GTK theme
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'gtk-theme',
      value: 'Pop-slim',
    },
  },
  // icon theme
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'icon-theme',
      value: 'Pop',
    },
  },
  // cursor theme
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.interface',
      key: 'cursor-theme',
      value: 'DMZ-White',
    },
  },

  // =================================================================
  //                              Mouse
  // =================================================================

  // do not accelerate mouse cursor
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.peripherals.mouse',
      key: 'natural-scroll',
      value: false,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.peripherals.mouse',
      key: 'speed',
      value: 0.6,
    },
  },
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.peripherals.mouse',
      key: 'accel-profile',
      value: 'flat',
    },
  },

  // on touchpad scroll down by sliding fingers up
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.peripherals.touchpad',
      key: 'natural-scroll',
      value: true,
    },
  },

  // =================================================================
  //                            Keyboard
  // =================================================================

  // use Capslock as an additional Escape
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.input-sources',
      key: 'xkb-options',
      value: "['caps:escape']",
    },
  },

  // set prefered keyboard layouts
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.input-sources',
      key: 'sources',
      value: "[('xkb', 'us'), ('xkb', 'cz+qwerty')]",
    },
  },

  // =================================================================
  //                            Sounds
  // =================================================================

  // disable system sounds
  {
    gnomeSettings: {
      schema: 'org.gnome.desktop.sound',
      key: 'event-sounds',
      value: false,
    },
  },
]
