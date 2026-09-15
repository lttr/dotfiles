#!/usr/bin/env -S deno run --allow-run --allow-read --allow-write --allow-env
/**
 * Browser router: picks a browser per URL instead of always using the default.
 *
 * Usage:
 *   browser-router <url>...        open URLs in the matching browser
 *   browser-router --test <url>... print which browser would be used
 *   browser-router --install       register as the system http/https handler
 *   browser-router --uninstall     restore the previous handlers
 *   browser-router --status        show the current handler per mime type
 */

type Browser = {
  name: string;
  /** Wayland app_id, used to raise the window after handing over the URLs. */
  appId: string;
  open: (urls: string[]) => Promise<void>;
};

const HOME = Deno.env.get("HOME")!;
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

/** Spawn detached — the browser outlives this process. */
function spawn(cmd: string, args: string[]) {
  new Deno.Command(cmd, { args, stdin: "null", stdout: "null", stderr: "null" })
    .spawn()
    .unref();
}

type Toplevel = {
  app_id: string;
  is_active: boolean;
  output: { has_focus: boolean };
};

/** Is `appId` the focused window on the focused output? */
async function isFocused(appId: string): Promise<boolean> {
  try {
    const out = await new Deno.Command("cosmic-ext-window-helper", {
      args: ["state"],
      stderr: "null",
    }).output();
    const windows: Toplevel[] = JSON.parse(new TextDecoder().decode(out.stdout));
    return windows.some((w) => w.app_id === appId && w.is_active && w.output.has_focus);
  } catch {
    return true; // no helper / unexpected output: nothing to wait for
  }
}

/**
 * Raise the browser window. Handing a URL to an already-running browser does
 * not raise it under Wayland/COSMIC — the compositor decides focus, and this
 * process is not the focused app. cosmic-ext-window-helper asks the compositor
 * directly; keep asking until the window really holds focus, because a window
 * that does not exist yet (cold start) or the short-lived second browser
 * process handing over the URL can both eat the first activation.
 */
async function raise(appId: string) {
  for (let i = 0; i < 10; i++) {
    await new Deno.Command("cosmic-ext-window-helper", {
      args: ["activate", `app_id = '${appId}'`],
      stdout: "null",
      stderr: "null",
    }).output().catch(() => undefined);
    await sleep(400);
    // Check twice: the browser process that hands over the URL exits around
    // now, and COSMIC then hands focus back to whatever had it before.
    if (await isFocused(appId)) {
      await sleep(700);
      if (await isFocused(appId)) return;
    }
  }
}

const FIREFOX: Browser = {
  name: "Firefox",
  appId: "firefox",
  open: (urls) => {
    spawn("/usr/lib/firefox/firefox-bin", urls);
    return Promise.resolve();
  },
};

/**
 * Edge must come up through `edgeopen`: it owns the dedicated automation
 * profile and the CDP debug port that the az-login and day-start skills
 * attach to. Launching Edge any other way would create a second,
 * non-debuggable instance on a different profile.
 */
const EDGE_OPEN = `${HOME}/bin/edgeopen`;
const EDGE_PROFILE = `${HOME}/.var/app/com.microsoft.Edge/config/microsoft-edge-az`;

const EDGE: Browser = {
  name: "Microsoft Edge",
  appId: "microsoft-edge",
  open: async (urls) => {
    // Starts Edge on the automation profile, or returns straight away when a
    // debuggable instance is already up.
    await new Deno.Command(EDGE_OPEN, { stdout: "null", stderr: "null" })
      .output()
      .catch(() => undefined);
    // Same --user-data-dir, so Edge's singleton lock hands the URLs to that
    // instance instead of starting another one. This process exits once the
    // hand-off is done; wait for it (capped, in case it ends up being the
    // browser itself) so the window is raised after the tab actually opens.
    const handoff = new Deno.Command("/usr/bin/flatpak", {
      args: [
        "run",
        "--branch=stable",
        "--arch=x86_64",
        "--command=/app/bin/edge",
        "com.microsoft.Edge",
        `--user-data-dir=${EDGE_PROFILE}`,
        ...urls,
      ],
      stdin: "null",
      stdout: "null",
      stderr: "null",
    }).spawn();
    handoff.unref();
    await Promise.race([handoff.status, sleep(5000)]);
  },
};

/**
 * Hosts routed to Edge. Matches the host itself and any subdomain of it,
 * so "sharepoint.com" also covers "drmax.sharepoint.com".
 */
const EDGE_HOSTS = [
  "dev.azure.com",
  "visualstudio.com",
  "sharepoint.com",
  "teams.microsoft.com",
  "cloud.microsoft", // outlook.cloud.microsoft, bookings.cloud.microsoft, ...
  "mydrmax.atlassian.net",
  "lucid.app",
  "drmax-gl.space",
  "drmax-cz.live",
];

/** Extra host patterns for Edge, tested against the hostname. */
const EDGE_HOST_PATTERNS = [/drmax-gl/];

const EDGE_HOST_RE = new RegExp(
  `^(.+\\.)?(${EDGE_HOSTS.map((h) => h.replace(/\./g, "\\.")).join("|")})$`,
);

/** First matching rule wins. */
const RULES: Array<{ match: (url: URL) => boolean; browser: Browser }> = [
  {
    match: (u) =>
      EDGE_HOST_RE.test(u.hostname) || EDGE_HOST_PATTERNS.some((re) => re.test(u.hostname)),
    browser: EDGE,
  },
];

const DEFAULT_BROWSER = FIREFOX;

const DESKTOP_ID = "browser-router.desktop";
const APPS_DIR = `${HOME}/.local/share/applications`;
const DESKTOP_PATH = `${APPS_DIR}/${DESKTOP_ID}`;
const BACKUP_PATH = `${HOME}/.local/state/browser-router/previous-defaults.json`;
const MIME_TYPES = [
  "x-scheme-handler/http",
  "x-scheme-handler/https",
  "text/html",
  "application/xhtml+xml",
];

function pick(url: string): Browser {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    return DEFAULT_BROWSER;
  }
  return RULES.find((r) => r.match(parsed))?.browser ?? DEFAULT_BROWSER;
}

async function open(urls: string[]) {
  const byBrowser = new Map<Browser, string[]>();
  for (const url of urls) {
    const b = pick(url);
    byBrowser.set(b, [...(byBrowser.get(b) ?? []), url]);
  }
  await Promise.all([...byBrowser].map(async ([browser, group]) => {
    await browser.open(group);
    await raise(browser.appId);
  }));
}

/**
 * mimeapps.list files that matter, most specific first. Desktop-specific lists
 * (e.g. cosmic-mimeapps.list under COSMIC) win over the generic one, and
 * `xdg-mime` only ever writes the generic one — so patch them all.
 */
function mimeappsFiles(): string[] {
  const desktops = (Deno.env.get("XDG_CURRENT_DESKTOP") ?? "")
    .split(":")
    .filter(Boolean)
    .map((d) => d.toLowerCase());
  const paths = [
    ...desktops.map((d) => `${HOME}/.config/${d}-mimeapps.list`),
    `${HOME}/.config/mimeapps.list`,
  ];
  return paths.filter((p) => {
    try {
      return Deno.statSync(p).isFile;
    } catch {
      return false;
    }
  });
}

/** Set `[Default Applications]` entries in one mimeapps.list; returns the replaced values. */
function setDefaults(path: string, entries: Record<string, string>): Record<string, string> {
  const lines = Deno.readTextFileSync(path).split("\n");
  const previous: Record<string, string> = {};
  const pending = new Set(Object.keys(entries));

  let groupStart = lines.findIndex((l) => l.trim() === "[Default Applications]");
  if (groupStart === -1) {
    lines.unshift("[Default Applications]", "");
    groupStart = 0;
  }
  let groupEnd = groupStart + 1;
  while (groupEnd < lines.length && !lines[groupEnd].trim().startsWith("[")) groupEnd++;

  for (let i = groupStart + 1; i < groupEnd; i++) {
    const key = lines[i].split("=")[0].trim();
    if (key in entries) {
      previous[key] = lines[i].slice(lines[i].indexOf("=") + 1).trim();
      lines[i] = `${key}=${entries[key]}`;
      pending.delete(key);
    }
  }
  const added = [...pending].map((k) => `${k}=${entries[k]}`);
  lines.splice(groupEnd, 0, ...added);

  Deno.writeTextFileSync(path, lines.join("\n"));
  return previous;
}

async function install() {
  Deno.writeTextFileSync(
    DESKTOP_PATH,
    `[Desktop Entry]
Type=Application
Name=Browser Router
GenericName=Web Browser
Comment=Opens URLs in a browser chosen by URL pattern
Exec=${HOME}/bin/browser-router %u
Terminal=false
NoDisplay=true
MimeType=${MIME_TYPES.join(";")};
Categories=Network;WebBrowser;
`,
  );

  const entries = Object.fromEntries(MIME_TYPES.map((m) => [m, DESKTOP_ID]));
  const backup: Record<string, Record<string, string>> = {};
  for (const path of mimeappsFiles()) {
    backup[path] = setDefaults(path, entries);
    console.log(`Patched ${path}`);
  }
  Deno.mkdirSync(BACKUP_PATH.replace(/\/[^/]+$/, ""), { recursive: true });
  Deno.writeTextFileSync(BACKUP_PATH, JSON.stringify(backup, null, 2));

  await new Deno.Command("update-desktop-database", { args: [APPS_DIR] }).output();
  console.log(`Installed ${DESKTOP_PATH}; previous defaults saved to ${BACKUP_PATH}`);
}

function uninstall() {
  let backup: Record<string, Record<string, string>> = {};
  try {
    backup = JSON.parse(Deno.readTextFileSync(BACKUP_PATH));
  } catch {
    console.warn(`No backup at ${BACKUP_PATH}; falling back to firefox.desktop`);
    backup = Object.fromEntries(
      mimeappsFiles().map((p) => [p, Object.fromEntries(MIME_TYPES.map((m) => [m, "firefox.desktop"]))]),
    );
  }
  for (const [path, entries] of Object.entries(backup)) {
    if (Object.keys(entries).length === 0) continue;
    setDefaults(path, entries);
    console.log(`Restored ${path}`);
  }
}

async function status() {
  for (const m of MIME_TYPES) {
    const out = await new Deno.Command("xdg-mime", { args: ["query", "default", m] }).output();
    console.log(`${m} -> ${new TextDecoder().decode(out.stdout).trim()}`);
  }
  for (const path of mimeappsFiles()) {
    const hit = Deno.readTextFileSync(path)
      .split("\n")
      .filter((l) => MIME_TYPES.some((m) => l.startsWith(`${m}=`)));
    console.log(`\n${path}\n  ${hit.join("\n  ")}`);
  }
}

const args = Deno.args;
switch (args[0]) {
  case undefined:
    console.error("usage: browser-router [--install|--uninstall|--status|--test] <url>...");
    Deno.exit(1);
  case "--install":
    await install();
    break;
  case "--uninstall":
    uninstall();
    break;
  case "--status":
    await status();
    break;
  case "--test":
    for (const url of args.slice(1)) console.log(`${url} -> ${pick(url).name}`);
    break;
  default:
    await open(args);
}
