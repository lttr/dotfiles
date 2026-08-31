#!/usr/bin/env -S deno run --allow-read --allow-run --allow-env

// lsimg
// Renders any number of images in the terminal as an ad-hoc album: a grid of
// kitty-rendered thumbnails, each with its file name underneath. Directories
// are scanned (non-recursively) for images. Everything is drawn with
// `kitten icat --place`, one grid row at a time, so albums longer than the
// screen simply scroll into the scrollback. See usage() for the options.

import { basename, extname } from "jsr:@std/path";

const IMAGE_EXT = new Set([
  ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".tif", ".tiff", ".avif",
  ".heic", ".heif", ".svg", ".ico",
]);

const enc = new TextEncoder();
const out = (s: string) => Deno.stdout.writeSync(enc.encode(s));

function usage(code = 0): never {
  console.log(
    [
      "Usage: lsimg [options] <image|dir> ...",
      "",
      "  -c, --cols N     number of columns (default: as few as fit on one screen)",
      "  -s, --size H     tile height in rows (default: square-ish, screen-fitted)",
      "  -n, --no-names   hide the file names",
      "  -h, --help       show this help",
    ].join("\n"),
  );
  Deno.exit(code);
}

function icat(args: string[], opts: Deno.CommandOptions) {
  return new Deno.Command("kitty", { args: ["+kitten", "icat", ...args], ...opts })
    .output();
}

// ---------------------------------------------------------------- arguments

let cols = 0;
let tileRows = 0;
let showNames = true;
const inputs: string[] = [];

function count(flag: string, raw: string | undefined): number {
  const n = Number(raw);
  if (!Number.isInteger(n) || n < 1) {
    console.error(`lsimg: ${flag} needs a positive whole number`);
    usage(1);
  }
  return n;
}

const argv = [...Deno.args];
while (argv.length) {
  const arg = argv.shift()!;
  switch (arg) {
    case "-h":
    case "--help":
      usage();
      break;
    case "-n":
    case "--no-names":
      showNames = false;
      break;
    case "-c":
    case "--cols":
      cols = count(arg, argv.shift());
      break;
    case "-s":
    case "--size":
      tileRows = count(arg, argv.shift());
      break;
    default:
      if (arg.startsWith("-")) {
        console.error(`Unknown option: ${arg}`);
        usage(1);
      }
      inputs.push(arg);
  }
}

if (!inputs.length) usage(1);
if (!Deno.stdout.isTerminal()) {
  console.error("lsimg: stdout is not a terminal");
  Deno.exit(1);
}

// ------------------------------------------------------------------- files

const { columns: termCols, rows: termRows } = Deno.consoleSize();

// Probing kitty is a subprocess spawn; let it run while the files are scanned.
const cellPixels = probeCellPixels();

const isImage = (path: string) => IMAGE_EXT.has(extname(path).toLowerCase());

const files: string[] = [];
for (const input of inputs) {
  let stat: Deno.FileInfo;
  try {
    stat = await Deno.stat(input);
  } catch {
    console.error(`lsimg: no such file or directory: ${input}`);
    continue;
  }
  if (stat.isDirectory) {
    const dir = input.replace(/\/$/, "");
    const entries = await Array.fromAsync(Deno.readDir(input));
    const found = entries
      .filter((e) => e.isFile && isImage(e.name))
      .map((e) => `${dir}/${e.name}`)
      .sort();
    for (const file of found) files.push(file);
  } else {
    files.push(input);
  }
}

if (!files.length) {
  console.error("lsimg: no images to show");
  Deno.exit(1);
}

// ------------------------------------------------------------------ layout

const GUTTER = 2; // horizontal gap between tiles, in cells
const PAD = Math.floor(GUTTER / 2); // half a gutter on each side of a tile
const VGAP = 1; // blank row between grid rows
const MIN_TILE_COLS = 12; // narrowest tile worth drawing
const MIN_TILE_ROWS = 3;

// Cell aspect ratio, so a square image gets a square-ish tile.
async function probeCellPixels(): Promise<{ w: number; h: number }> {
  try {
    const { stdout } = await icat(["--print-window-size"], {
      stdout: "piped",
      stderr: "null",
    });
    const [w, h] = new TextDecoder().decode(stdout).trim().split("x").map(Number);
    if (w > 0 && h > 0) return { w: w / termCols, h: h / termRows };
  } catch { /* fall through to a sane default */ }
  return { w: 9, h: 19 };
}

const cell = await cellPixels;
const captionRows = showNames ? 1 : 0;
const usableRows = termRows - 1; // the cursor keeps the last screen row

// Rows a band takes: the tile, its caption and the gap below it.
const bandOf = (tile: number) => tile + captionRows + VGAP;
// Square-ish tile height for a given tile width.
const tileHeightFor = (width: number) =>
  Math.round(((width - GUTTER) * cell.w) / cell.h);

const maxTileRows = usableRows - captionRows - VGAP;
const maxCols = Math.max(1, Math.floor(termCols / MIN_TILE_COLS));
if (maxTileRows < MIN_TILE_ROWS || termCols < 8) {
  console.error("lsimg: terminal is too small to draw anything");
  Deno.exit(1);
}

// Tile height that a given column count yields, within the screen's limits.
const tileRowsFor = (n: number) =>
  Math.min(maxTileRows, Math.max(MIN_TILE_ROWS, tileHeightFor(Math.floor(termCols / n))));

if (cols > maxCols) {
  console.error(
    `lsimg: -c ${cols} does not fit; the terminal has room for ${maxCols} columns`,
  );
  Deno.exit(1);
}

if (!cols) {
  // Pick the column count that makes the tiles as large as possible while the
  // whole album still fits on one screen; if it cannot, settle for bands of at
  // most half a screen so a few rows stay visible together.
  const halfScreen = Math.max(
    MIN_TILE_ROWS,
    Math.floor(usableRows / 2) - captionRows - VGAP,
  );
  const candidates = Array.from(
    { length: Math.min(files.length, maxCols) },
    (_, i) => i + 1,
  );
  cols = candidates.find((n) =>
    Math.ceil(files.length / n) * bandOf(tileRowsFor(n)) <= usableRows
  ) ??
    candidates.find((n) => tileRowsFor(n) <= halfScreen) ??
    maxCols;
}

const tileCols = Math.floor(termCols / cols);
const imgCols = Math.max(1, tileCols - GUTTER);
// Center the whole grid horizontally.
const marginCols = Math.floor((termCols - cols * tileCols) / 2);
// Screen column of the nth tile in a band.
const tileX = (n: number) => marginCols + PAD + n * tileCols;

if (tileRows > maxTileRows) {
  console.error(
    `lsimg: -s ${tileRows} does not fit; the terminal has room for ` +
      `${maxTileRows} rows`,
  );
  Deno.exit(1);
} else if (!tileRows) {
  tileRows = tileRowsFor(cols);
}
const bandRows = bandOf(tileRows);

// ------------------------------------------------------------------ render

function label(name: string, width: number): string {
  if (name.length <= width) {
    const pad = width - name.length;
    const left = Math.floor(pad / 2);
    return " ".repeat(left) + name + " ".repeat(pad - left);
  }
  const keep = width - 1;
  const head = Math.ceil(keep / 2);
  const tail = keep - head;
  return name.slice(0, head) + "…" + (tail ? name.slice(-tail) : "");
}

const place = (file: string, x: number, top: number) =>
  icat([
    "--align=center",
    "--stdin=no",
    `--place=${imgCols}x${tileRows}@${x}x${top}`,
    file,
  ], { stdin: "null", stdout: "inherit", stderr: "null" });

for (let i = 0; i < files.length; i += cols) {
  const rowFiles = files.slice(i, i + cols);

  // Scroll a fresh band into view; the cursor ends up on the last screen row.
  out("\n".repeat(bandRows));
  const top = termRows - bandRows; // 0-based screen row of the band top

  for (const [n, file] of rowFiles.entries()) {
    await place(file, tileX(n), top);
  }

  if (showNames) {
    // Captions go on the row right below the tiles; the trailing gap row keeps
    // them from touching the next band. Stay one cell short of the right edge
    // so the terminal does not auto-wrap and scroll on us.
    const line = " ".repeat(tileX(0)) +
      rowFiles
        .map((f) => label(basename(f), imgCols))
        .join(" ".repeat(GUTTER));
    out(`\x1b[${termRows - VGAP};1H\x1b[2K${line.slice(0, termCols - 1)}`);
  }

  out(`\x1b[${termRows};1H`);
}

out("\n");
