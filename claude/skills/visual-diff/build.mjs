#!/usr/bin/env node
// Wrap a report body in the scaffold.
//
//   node build.mjs <body.html> --title "Visual diff: subject" [--out <file>] [--open]
//
// The body is everything from <main> to </main>. The scaffold supplies the head,
// the palette, and the loader, so you never copy those by hand.
//
// Without --out the page lands in the OS temp directory as
// <YYYY-MM-DD>-visual-diff-<slug>.html. The final path is always printed.

import { readFileSync, writeFileSync } from "node:fs";
import { spawn } from "node:child_process";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const argv = process.argv.slice(2);
const flag = (name) => {
  const i = argv.indexOf(name);
  return i >= 0 ? argv.splice(i, 2)[1] : undefined;
};
const has = (name) => {
  const i = argv.indexOf(name);
  return i >= 0 ? (argv.splice(i, 1), true) : false;
};

const title = flag("--title");
let outPath = flag("--out");
const open = has("--open");
const [bodyPath] = argv;

if (!bodyPath) {
  console.error("usage: build.mjs <body.html> --title <title> [--out <file>] [--open]");
  process.exit(2);
}

const MARKER = "<!-- BODY -->";
const scaffoldPath = join(dirname(fileURLToPath(import.meta.url)), "scaffold.html");

const read = (path, what) => {
  try {
    return readFileSync(path, "utf8");
  } catch (err) {
    console.error(`cannot read ${what}: ${err.message}`);
    process.exit(1);
  }
};

const scaffold = read(scaffoldPath, "the scaffold");
const body = read(bodyPath, "the body");

if (!scaffold.includes(MARKER)) {
  console.error(`${scaffoldPath} has no ${MARKER} marker`);
  process.exit(1);
}

let out = scaffold.replace(MARKER, () => body.trimEnd());
if (title) {
  const safe = title.replace(/&/g, "&amp;").replace(/</g, "&lt;");
  out = out.replace(/<title>[\s\S]*?<\/title>/, () => `<title>${safe}</title>`);
} else {
  console.error("warning: no title given, the page will read just \"Visual diff\"");
}

if (!outPath) {
  const date = new Date().toISOString().slice(0, 10);
  const slug = (title ?? "report")
    .replace(/^visual diff:?/i, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "") || "report";
  outPath = join(tmpdir(), `${date}-visual-diff-${slug}.html`);
}

// The one sequence that would end a <script type="text/plain"> block early.
const stray = body.split("\n").findIndex((l) => /<\/script(?![ >])/i.test(l));
if (stray >= 0) {
  console.error(`warning: line ${stray + 1} of the body looks like a broken </script`);
}

writeFileSync(outPath, out);
console.log(outPath);

if (open) {
  const cmd = process.platform === "darwin"
    ? ["open", [outPath]]
    : process.platform === "win32"
      ? ["cmd", ["/c", "start", "", outPath]]
      : ["xdg-open", [outPath]];
  const child = spawn(cmd[0], cmd[1], { stdio: "ignore", detached: true });
  child.on("error", (err) => console.error(`cannot open the page: ${err.message}`));
  child.unref();
}
