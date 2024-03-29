// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.

module.exports = {
  config: {
    // choose either `'stable'` for receiving highly polished,
    // or `'canary'` for less polished but more frequent updates
    updateChannel: "stable",

    // default font size in pixels for all tabs
    fontSize: 13.5,
    lineHeight: 1.2,

    windowSize: [1100, 800],

    // font family with optional fallbacks
    // Windows
    // fontFamily: 'Consolas, "DejaVu Sans Mono", "Lucida Console", monospace',

    // Linux Pop OS
    fontFamily:
      '"Fira Mono Regular", "DejaVu Sans Mono", "Consolas", monospace',

    // default font weight: 'normal' or 'bold'
    fontWeight: "normal",

    // font weight for bold characters: 'normal' or 'bold'
    fontWeightBold: "bold",

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    // cursorColor: 'rgba(101,123,131,0.8)',

    // terminal text color under BLOCK cursor
    cursorAccentColor: "#fdf6e3",

    // `'BEAM'` for |, `'UNDERLINE'` for _, `'BLOCK'` for █
    // cursorShape: 'UNDERLINE',
    cursorShape: "BLOCK",

    // set to `true` (without backticks and without quotes) for blinking cursor
    cursorBlink: false,

    // color of the text
    // foregroundColor: '#657b83', // solarized light
    // foregroundColor: '#fdf6e3', // solarized dark

    // terminal background color
    // opacity is only supported on macOS
    // backgroundColor: '#fdf6e3', //solarized light
    // backgroundColor: '#657b83', // solarized dark

    // terminal selection color
    selectionColor: "rgba(147,161,161,0.3)",

    themeOptions: {
      foregroundColor: "#c5c8c6",
      backgroundColor: "#393939", // tomorrow night # base3
      // border color (window, tabs)
      borderColor: "#393939",
      cursorColor: "#828482",
    },

    // custom CSS to embed in the main window
    css: `
      .tabs_nav {
        height: 28px;
        line-height: 28px;
        font-size: 11px;
      }
      .tabs_list {
        max-height: 28px;
      }
      .tab_icon {
        color: #444;
        opacity: 0.8;
        top: 7px;
      }
      .tab_iconHovered {
        background-color: #ccc;
      }
    `,

    // custom CSS to embed in the terminal window
    termCSS: "",

    // if you're using a Linux setup which show native menus, set to false
    // default: `true` on Linux, `true` on Windows, ignored on macOS
    showHamburgerMenu: true,

    // set to `false` (without backticks and without quotes) if you want to hide the minimize, maximize and close buttons
    // additionally, set to `'left'` if you want them on the left, like in Ubuntu
    // default: `true` (without backticks and without quotes) on Windows and Linux, ignored on macOS
    showWindowControls: true,

    // custom padding (CSS format, i.e.: `top right bottom left`)
    padding: "7px 9px",

    // the full list. if you're going to provide the full color palette,
    // including the 6 x 6 color cubes and the grayscale map, just provide
    // an array here instead of a color map object
    // colors: {
    //   black: '#000000',
    //   red: '#C51E14',
    //   green: '#1DC121',
    //   yellow: '#C7C329',
    //   blue: '#0A2FC4',
    //   magenta: '#C839C5',
    //   cyan: '#20C5C6',
    //   white: '#C7C7C7',
    //   lightBlack: '#686868',
    //   lightRed: '#FD6F6B',
    //   lightGreen: '#67F86F',
    //   lightYellow: '#FFFA72',
    //   lightBlue: '#6A76FB',
    //   lightMagenta: '#FD7CFC',
    //   lightCyan: '#68FDFE',
    //   lightWhite: '#FFFFFF',
    // },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    //
    // Windows
    // - Make sure to use a full path if the binary name doesn't work
    // - Remove `--login` in shellArgs
    //
    // Bash on Windows
    // - Example: `C:\\Windows\\System32\\bash.exe`
    //
    // for setting shell arguments (i.e. for using interactive shellArgs: `['-i']`)
    // by default `['--login']` will be used

    shell: "zsh",

    // Bash
    // shell: 'C:\\Windows\\System32\\bash.exe',
    // shellArgs: ['--login', '-c', 'zsh'],

    // Windows PowerShell
    // shell: 'C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe',
    // shellArgs: ['-NoLogo'],

    // Pwsh
    // shell: 'C:\\Program Files\\PowerShell\\6\\pwsh.exe',
    // shellArgs: [],

    // Hyperstart
    // shell: '',
    // shellArgs: ['/C', 'C:\\Users\\Lukas\\dotfiles\\hyperterm\\hyperstart.bat'],

    // for environment variables
    env: {},

    // set to `false` for no bell
    bell: "false",

    // if `true` (without backticks and without quotes), selected text will automatically be copied to the clipboard
    copyOnSelect: true,

    // if `true` (without backticks and without quotes), hyper will be set as the default protocol client for SSH
    defaultSSHApp: true,

    // if `true` (without backticks and without quotes), on right click selected text will be copied or pasted if no
    // selection is present (`true` by default on Windows and disables the context menu feature)
    quickEdit: true,

    // Whether to use the WebGL renderer. Set it to false to use canvas-based
    // rendering (slower, but supports transparent backgrounds)
    webGLRenderer: false,

    // for advanced config flags please refer to https://hyper.is/#cfg

    hyperTabsMove: {
      moveLeft: "ctrl+shift+pageup",
      moveRight: "ctrl+shift+pagedown",
    },
  },

  plugins: [
    "hyper-search",
    "hypercwd",
    "hyperterm-tabs",
    "hyper-native-window-decoration",
    "hyperlayout",
    "hyperterm-base16-tomorrow-dark",
  ],

  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  // localPlugins: ['hyper-solarized-light'],
  // localPlugins: ['hyper-solarized-dark'],

  keymaps: {
    "pane:splitHorizontal": "ctrl+shift+h",
  },
};
