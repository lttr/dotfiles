import { HOME } from "../constants.ts";
import type { Config } from "../deps.ts";
import { aptUpdate, gnupg2 } from "./apt.ts";

interface ReleaseAsset {
  name: string;
  browser_download_url: string;
}

interface Release {
  draft: boolean;
  prerelease: boolean;
  assets: ReleaseAsset[];
}

/**
 * Finds the .deb download URL in the newest published release that has one.
 * Not every release carries a .deb - repos often publish other platforms from
 * the same tag stream - so the newest release is not necessarily the newest
 * one we can install. Drafts and prereleases are skipped, and amd64 wins when
 * a release offers several architectures.
 * @param repo - GitHub repo in format "owner/repo"
 * @returns Promise with the download URL or throws if none of the recent
 *          releases has a .deb
 */
async function getGitHubReleaseDebUrl(repo: string): Promise<string> {
  const response = await fetch(
    `https://api.github.com/repos/${repo}/releases?per_page=30`,
    {
      headers: {
        Accept: "application/vnd.github+json",
      },
    },
  );

  if (!response.ok) {
    throw new Error(`Failed to fetch releases for ${repo}: ${response.status}`);
  }

  const releases: Release[] = await response.json();
  for (const release of releases) {
    if (release.draft || release.prerelease) continue;
    const debAssets = release.assets.filter((asset) =>
      asset.name.endsWith(".deb")
    );
    if (!debAssets.length) continue;
    const amd64Asset = debAssets.find((asset) => asset.name.includes("amd64"));
    return (amd64Asset ?? debAssets[0]).browser_download_url;
  }

  throw new Error(`No .deb file found in the recent releases of ${repo}`);
}

/** Whether a program of this name (or absolute path) exists. */
async function isInstalled(name: string): Promise<boolean> {
  try {
    const { success } = await new Deno.Command("sh", {
      args: ["-c", `command -v ${name}`],
      stdout: "null",
      stderr: "null",
    }).output();
    return success;
  } catch {
    return false;
  }
}

/**
 * A .deb package installed from a GitHub release, as a list so it can be
 * spread into a config set and be empty. The release lookup is the one piece
 * of this configuration that needs the network, so it runs only when the
 * program is actually missing, and a repo without a usable release drops just
 * this package instead of failing the whole run.
 */
async function gitHubDebPackage(
  name: string,
  repo: string,
  executable?: string,
): Promise<Config[]> {
  if (await isInstalled(executable ?? name)) return [];
  try {
    return [{
      debianPackage: {
        name,
        url: await getGitHubReleaseDebUrl(repo),
        executable,
      },
    }];
  } catch (error) {
    console.warn(
      `Skipping ${name}: ${error instanceof Error ? error.message : error}`,
    );
    return [];
  }
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

// Obsidian and Ferdium - fetched from GitHub releases
// Obsidian is checked by absolute path because its CLI helper in ~/.local/bin
// shadows the app on PATH.
const obsidian = await gitHubDebPackage(
  "obsidian",
  "obsidianmd/obsidian-releases",
  "/opt/Obsidian/obsidian",
);
const ferdium = await gitHubDebPackage("ferdium", "ferdium/ferdium-app");

// Update: curl -fsSL https://vite.plus | bash
export const vitePlus: Config = {
  urlScript: {
    name: "vite-plus",
    url: "https://vite.plus",
    executable: "vp",
  },
};

export const node: Config = {
  inlineScript: {
    name: "node",
    testScript: "vp env current | grep 24",
    setScript: "vp env default 24 && vp env install",
  },
  dependsOn: vitePlus,
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

/**
 * Docker daemon from Docker's Ubuntu apt repo. The Debian repo's containerd.io
 * needs a newer libseccomp2 than noble ships. The brew `docker` is only the CLI.
 */
const dockerEngine: Config = {
  inlineScript: {
    name: "docker-engine",
    testScript: "command -v dockerd",
    setScript: `
      set -e
      sudo install -m 0755 -d /etc/apt/keyrings
      if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
          -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
      fi
      echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt-get update
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    `,
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
  { name: "tokei" },
  { name: "unison" },
  { name: "yt-dlp" },
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
    // The aka.ms installer fails on any broken apt repo; plain apt suffices
    // once Microsoft's repo is configured.
    setScript: `
      sudo apt-get install -y azure-cli ||
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

function vpGlobal(
  { name, executable, lib }: {
    name: string;
    executable?: string;
    lib?: boolean;
  },
): Config {
  return {
    inlineScript: {
      name: `vp-global-${executable || name}`,
      testScript: lib
        ? `vp list -g ${name} 2>/dev/null | grep -q "${name}"`
        : `command -v ${executable || name}`,
      setScript: `vp install -g ${name}`,
      dependsOn: vitePlus,
    },
  };
}

const vpGlobalPackages: Config[] = [
  vpGlobal({ name: "@ast-grep/cli", executable: "sg" }),
  vpGlobal({ name: "@typescript-eslint/eslint-plugin", lib: true }),
  vpGlobal({ name: "@typescript-eslint/parser", lib: true }),
  vpGlobal({ name: "@vue/typescript-plugin", lib: true }),
  vpGlobal({ name: "browser-sync" }),
  vpGlobal({ name: "degit" }),
  vpGlobal({ name: "eslint" }),
  vpGlobal({ name: "eslint-formatter-unix", lib: true }),
  vpGlobal({ name: "git-standup" }),
  vpGlobal({ name: "hygen" }),
  vpGlobal({ name: "json" }),
  vpGlobal({ name: "nx" }),
  vpGlobal({ name: "oxfmt" }),
  vpGlobal({ name: "oxlint" }),
  vpGlobal({ name: "pollinate" }),
  vpGlobal({ name: "prettier" }),
  vpGlobal({ name: "sharp-cli", executable: "sharp" }),
  vpGlobal({ name: "stylelint" }),
  vpGlobal({ name: "stylelint-lsp" }),
  vpGlobal({ name: "taze" }),
  vpGlobal({ name: "typescript-language-server" }),
];

export const customInstalls: Config[] = [
  aptUpdate,
  at,
  azureCli,
  brew,
  claudeCode,
  cursors,
  dockerEngine,
  exp,
  ...ferdium,
  ffmpeg7,
  vitePlus,
  fzf,
  fzfSetup,
  gitCredentialLibsecret,
  googleChrome,
  kitty,
  nerdFont,
  neovim,
  neovimDeps,
  node,
  ...obsidian,
  onePassword,
  pnpm,
  soundSwitcherIndicator,
  ...brewPackages.map((brewConfig) => ({
    brew: { ...brewConfig, dependsOn: brew },
  })),
  ...vpGlobalPackages,
];
