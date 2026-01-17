import { HOME } from "../constants.ts";
import type { Config } from "../deps.ts";
import { aptUpdate, gnupg2 } from "./apt.ts";

/**
 * Fetches the latest .deb release URL from a GitHub repository.
 * Automatically selects amd64 architecture when multiple .deb files exist.
 * @param repo - GitHub repo in format "owner/repo"
 * @returns Promise with the download URL or throws if not found
 */
async function getGitHubReleaseDebUrl(repo: string): Promise<string> {
  const response = await fetch(
    `https://api.github.com/repos/${repo}/releases/latest`,
    {
      headers: {
        Accept: "application/vnd.github+json",
      },
    },
  );

  if (!response.ok) {
    throw new Error(`Failed to fetch releases for ${repo}: ${response.status}`);
  }

  const release = await response.json();
  const debAssets = release.assets.filter((asset: { name: string }) =>
    asset.name.endsWith(".deb")
  );

  if (debAssets.length === 0) {
    throw new Error(`No .deb file found in latest release for ${repo}`);
  }

  // If multiple .deb files, prefer amd64
  let debAsset = debAssets[0];
  if (debAssets.length > 1) {
    const amd64Asset = debAssets.find((asset: { name: string }) =>
      asset.name.includes("amd64")
    );
    if (amd64Asset) {
      debAsset = amd64Asset;
    }
  }

  return debAsset.browser_download_url;
}

// Google Chrome - update is built in and automatic via apt
export const googleChrome: Config = {
  debianPackage: {
    name: "google-chrome",
    url:
      "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb",
  },
};

// 1Password
export const onePassword: Config = {
  debianPackage: {
    name: "1password",
    url:
      "https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb",
    dependsOn: gnupg2,
  },
};

// Obsidian - fetched from GitHub releases
const obsidianDebUrl = await getGitHubReleaseDebUrl(
  "obsidianmd/obsidian-releases",
);
export const obsidian: Config = {
  debianPackage: {
    name: "obsidian",
    url: obsidianDebUrl,
  },
};

// Ferdium - fetched from GitHub releases
const ferdiumDebUrl = await getGitHubReleaseDebUrl("ferdium/ferdium-app");
export const ferdium: Config = {
  debianPackage: {
    name: "ferdium",
    url: ferdiumDebUrl,
  },
};

// Claude Desktop - fetched from GitHub releases
const claudeDesktopDebUrl = await getGitHubReleaseDebUrl(
  "aaddrick/claude-desktop-debian",
);
export const claudeDesktop: Config = {
  debianPackage: {
    name: "claude-desktop",
    url: claudeDesktopDebUrl,
  },
};

// Update:
// curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
export const fnm: Config = {
  urlScript: {
    name: "fnm",
    url: "https://fnm.vercel.app/install",
  },
};

export const node: Config = {
  inlineScript: {
    name: "node",
    testScript:
      'eval "$(~/.local/share/fnm/fnm env)" && ~/.local/share/fnm/fnm current | grep 22',
    setScript:
      'eval "$(~/.local/share/fnm/fnm env)" && ~/.local/share/fnm/fnm install 22',
  },
  dependsOn: fnm,
};

// Update: brew update
const brew: Config = {
  urlScript: {
    name: "brew",
    url: "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh",
    postInstall:
      "mkdir -p ~/.local/bin && ln -s /home/linuxbrew/.linuxbrew/bin/brew ~/.local/bin/",
  },
};

const exp: Config = {
  inlineScript: {
    name: "exp",
    testScript: "test -f ~/opt/exp",
    setScript:
      "curl https://raw.githubusercontent.com/troydm/exp/master/exp -o ~/opt/exp && chmod +x ~/opt/exp",
  },
};

// Update:
// curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
const kitty: Config = {
  urlScript: {
    name: "kitty",
    url: "https://sw.kovidgoyal.net/kitty/installer.sh",
    postInstall: `
      mkdir -p ~/.local/bin
      # Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in your system-wide PATH)
      ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
      # Place the kitty.desktop file somewhere it can be found by the OS
      cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
      # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
      cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
      # Update the paths to the kitty and its icon in the kitty.desktop file(s)
      sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
      sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
    `,
  },
};

const pnpm: Config = {
  urlScript: {
    name: "pnpm",
    url: "https://get.pnpm.io/install.sh",
    postInstall:
      "mkdir -p ~/.local/bin && ln -s ~/.local/share/pnpm/pnpm ~/.local/bin/",
  },
};

const claudeCode: Config = {
  urlScript: {
    name: "claude",
    url: "https://claude.ai/install.sh",
  },
};

const brewPackages = [
  { name: "antidote", executable: "atuin" }, // A hact to not install antidote every time, since there is no executable for it
  { name: "atuin" },
  { name: "git-delta", executable: "delta" },
  { name: "docker" },
  { name: "docker-compose" },
  { name: "eza" },
  { name: "gh" },
  { name: "glab" },
  { name: "httpie" },
  { name: "potrace" },
  { name: "rg" },
  { name: "sd" },
  { name: "unison" },
  { name: "zoxide" },
];

export const neovim: Config = {
  brew: {
    name: "nvim",
    dependsOn: brew,
  },
};

const neovimDeps: Config = {
  inlineScript: {
    name: "NeovimDependencies",
    testScript: `ls ~/.local/share/nvim/site 2>&1 >/dev/null`,
    setScript:
      `nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'`,
    dependsOn: neovim,
  },
};

const fzf: Config = {
  brew: {
    name: "fzf",
    dependsOn: brew,
  },
};

const fzfSetup: Config = {
  inlineScript: {
    name: "fzfSetup",
    testScript: `ls "${HOME}/.fzf.zsh" 2>&1 >/dev/null`,
    setScript: `
      $(brew --prefix)/opt/fzf/install --no-update-rc
    `,
    dependsOn: fzf,
  },
};

const nerdFont: Config = {
  inlineScript: {
    name: "FiraMonoFont",
    testScript:
      `ls "${HOME}/.fonts/FiraMonoNerdFontMono-Regular.otf" 2>&1 >/dev/null`,
    setScript: `
      FONT_FILE_NAME="FiraMonoNerdFontMono-Regular.otf"
      FONT_TARGET_DIR="${HOME}/.fonts/"
      cd ~/Downloads
      curl -fsLo "$FONT_FILE_NAME" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/FiraMono/Regular/FiraMonoNerdFontMono-Regular.otf
      mkdir -p "$FONT_TARGET_DIR"
      mv "$FONT_FILE_NAME" "$FONT_TARGET_DIR"
      fc-cache -f
      `,
  },
};

const soundSwitcherIndicator: Config = {
  inlineScript: {
    name: "soundSwitcherIndicator",
    testScript: `dpkg -l indicator-sound-switcher 2>/dev/null | grep -q "^ii"`,
    setScript: `
      sudo apt-add-repository -y ppa:yktooo/ppa
      sudo apt-get update
      sudo apt-get install -y indicator-sound-switcher
    `,
  },
};

const at: Config = {
  inlineScript: {
    name: "at",
    testScript: `command -v at && systemctl is-enabled atd`,
    setScript: `
      sudo apt-get install -y at
      sudo systemctl enable --now atd
    `,
  },
};

const ffmpeg7: Config = {
  inlineScript: {
    name: "ffmpeg7",
    testScript: `ffmpeg -version 2>/dev/null | grep -q "ffmpeg version 7"`,
    setScript: `
      sudo add-apt-repository -y ppa:ubuntuhandbook1/ffmpeg7
      sudo apt-get update
      sudo apt-get install -y ffmpeg
    `,
  },
};

const gitCredentialLibsecret: Config = {
  inlineScript: {
    name: "git-credential-libsecret",
    testScript: "command -v git-credential-libsecret",
    setScript: `
      sudo apt install -y libsecret-1-dev
      sudo make -C /usr/share/doc/git/contrib/credential/libsecret
      sudo ln -sf /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret /usr/local/bin/
    `,
  },
};

const azureCli: Config = {
  inlineScript: {
    name: "azure-cli",
    testScript: "command -v az && az extension show --name azure-devops",
    setScript: `
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      az extension add --name azure-devops
    `,
  },
};

export const cursors: Config = {
  inlineScript: {
    name: "cursors",
    testScript: `ls "/usr/share/icons/BreezeX-Dark/" 2>&1 >/dev/null`,
    setScript: `
      set -e
      CURSORS_FILE_NAME="BreezeX-Dark.tar.xz"
      CURSORS_TARGET_DIR="/usr/share/icons/"
      mkdir -p ~/Downloads
      cd ~/Downloads
      rm -f "$CURSORS_FILE_NAME"
      curl -fSLo "$CURSORS_FILE_NAME" https://github.com/ful1e5/BreezeX_Cursor/releases/download/v2.0.1/BreezeX-Dark.tar.xz
      if [ ! -f "$CURSORS_FILE_NAME" ]; then
        echo "Error: Failed to download cursor theme"
        exit 1
      fi
      rm -rf BreezeX-Dark/
      tar -xvf "$CURSORS_FILE_NAME"
      sudo mv BreezeX-Dark/ "$CURSORS_TARGET_DIR"
    `,
  },
};

const pnpmPackages = [
  { name: "@antfu/ni", executable: "ni" },
  { name: "browser-sync" },
  { name: "degit" },
  { name: "eslint" },
  { name: "eslint_d" },
  { name: "firebase-tools", executable: "firebase" },
  { name: "git-standup" },
  { name: "hygen" },
  { name: "json" },
  { name: "netlify-cli", executable: "netlify" },
  { name: "npm-why" },
  { name: "nx" },
  { name: "open-cli" },
  { name: "pollinate" },
  { name: "prettier" },
  { name: "@fsouza/prettierd", executable: "prettierd" },
  { name: "sharp-cli", executable: "sharp" },
  { name: "stylelint" },
  { name: "typescript-language-server" },
];

export const customInstalls: Config[] = [
  aptUpdate,
  at,
  azureCli,
  brew,
  claudeCode,
  claudeDesktop,
  cursors,
  exp,
  ferdium,
  ffmpeg7,
  fnm,
  fzf,
  fzfSetup,
  gitCredentialLibsecret,
  googleChrome,
  kitty,
  nerdFont,
  neovim,
  neovimDeps,
  node,
  obsidian,
  onePassword,
  pnpm,
  soundSwitcherIndicator,
  ...brewPackages.map((brewConfig) => ({
    brew: { ...brewConfig, dependsOn: brew },
  })),
  ...pnpmPackages.map((pnpmConfig) => {
    return {
      pnpmGlobalInstall: { ...pnpmConfig, dependsOn: pnpm },
    };
  }),
];
