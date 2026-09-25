#!/usr/bin/env -S deno run --allow-run --allow-env --allow-read --allow-write
// Compare `/context` output of `claude -p` across models and setting-source variants.
// Runs in the cwd, so project settings/CLAUDE.md of the cwd are included.
// Deferred tools, compact buffer and free space are omitted: they don't occupy the context.
//
// Usage: claude-context-compare [--raw] [--cost] [--html [file]]
//   --raw          also print each run's full /context output
//   --cost         also send "hi" twice per run (first call + cached repeat) and report the price (costs money)
//   --savings      also measure what each setting in ~/.claude/settings.json saves on its own (free, /context only)
//   --html [file]  write a stacked bar chart (default /tmp/claude-context-compare.html) and open it
import $ from "jsr:@david/dax";

const models = ["opus", "fable", "sonnet"];
const variants: Record<string, { flags: string[]; desc: string }> = {
  "Lukas' config": { flags: [], desc: "Lukas' stricter config: user + project + local settings, with deny rules, Concise output style and trimmed skills, plus user plugins, skills and agents." },
  'sources ""': { flags: ["--setting-sources", ""], desc: "No settings files loaded and no CLAUDE.md: the closest to stock Claude Code without any config." },
  "sources project": { flags: ["--setting-sources", "project"], desc: "Only the shared project settings plus the CLAUDE.md files found in the project tree: what stock Claude Code loads for everyone on the project." },
  "bare": { flags: ["--bare"], desc: "Barebones mode: skips hooks, plugins, LSP, auto-memory and CLAUDE.md, with a minimal system prompt and core tools only." },
};
const omitted = /deferred|buffer|Free space/i;
// Subsections whose rows are counted (e.g. number of loaded skills)
const counted = ["Skills", "Custom Agents", "Memory Files", "MCP Tools"];

type Parsed = { modelId: string; total: string; categories: Map<string, string>; counts: Map<string, number>; raw: string };

function parse(raw: string): Parsed {
  const categories = new Map<string, string>();
  const counts = new Map<string, number>();
  const modelId = raw.match(/\*\*Model:\*\*\s*(\S+)/)?.[1] ?? "?";
  const total = raw.match(/\*\*Tokens:\*\*\s*([^\s/]+)/)?.[1] ?? "?";
  let section = "";
  let header = true;
  for (const line of raw.split("\n")) {
    const heading = line.match(/^###\s+(.+)/);
    if (heading) {
      section = heading[1].trim();
      header = true;
      continue;
    }
    if (!line.startsWith("|") || /^\|[-\s|]+\|$/.test(line)) continue;
    if (header) {
      header = false;
      continue;
    }
    const cells = line.split("|").slice(1, -1).map((c) => c.trim());
    if (section.startsWith("Estimated usage")) {
      if (!omitted.test(cells[0])) categories.set(cells[0], cells[1]);
    } else if (counted.includes(section)) {
      counts.set(section, (counts.get(section) ?? 0) + 1);
    }
  }
  return { modelId, total, categories, counts, raw };
}

const runs = models.flatMap((model) =>
  Object.entries(variants).map(([variant, { flags }]) => {
    const args = ["-p", "/context", "--model", model, ...flags];
    // A per-run nonce busts any prompt cache left over from earlier runs, so the first call is truly cold
    const nonce = `cache-bust ${crypto.randomUUID().slice(0, 8)}`;
    const hiArgs = ["-p", "hi", "--output-format", "json", "--append-system-prompt", nonce, "--model", model, ...flags];
    return { label: `${model} / ${variant}`, model, variant, args, hiArgs, command: shell(args), hiCommand: shell(hiArgs) };
  })
);
const results = await Promise.all(runs.map(async (r) => {
  const raw = await $`claude ${r.args}`.stdin("null").noThrow().stderr("inheritPiped").text();
  return { label: r.label, ...parse(raw) };
}));

type Call = { cost: number; input: number; cacheWrite: number; cacheRead: number; output: number };
type Cost = { first?: Call; repeat?: Call; error?: string };

async function hi(args: string[]): Promise<Call> {
  const out = await $`claude ${args}`.stdin("null").noThrow().stderr("piped").text();
  let j;
  try {
    j = JSON.parse(out);
  } catch {
    throw new Error(out.trim().slice(0, 80) || "no output");
  }
  if (j.is_error) {
    const msg = String(j.result);
    throw new Error(/not logged in/i.test(msg) && args.includes("--bare") ? "--bare needs ANTHROPIC_API_KEY (ignores OAuth login)" : msg.slice(0, 80));
  }
  const u = j.usage;
  return {
    cost: j.total_cost_usd,
    input: u.input_tokens + u.cache_creation_input_tokens + u.cache_read_input_tokens,
    cacheWrite: u.cache_creation_input_tokens,
    cacheRead: u.cache_read_input_tokens,
    output: u.output_tokens,
  };
}

// Sequential per run so the repeat can hit the cache written by the first call
const costs: Cost[] | undefined = Deno.args.includes("--cost")
  ? await Promise.all(runs.map(async (r) => {
    try {
      const first = await hi(r.hiArgs);
      return { first, repeat: await hi(r.hiArgs) };
    } catch (e) {
      return { error: (e as Error).message };
    }
  }))
  : undefined;

// ---------- savings: one user setting at a time on top of no settings ----------

type Saving = { label: string; deltas: Record<string, number> };

function totalTokens(p: Parsed): number {
  return [...p.categories.values()].reduce((a, v) => a + toTokens(v), 0);
}

async function pool<T, R>(items: T[], size: number, fn: (t: T) => Promise<R>): Promise<R[]> {
  const out: R[] = new Array(items.length);
  let next = 0;
  await Promise.all(Array.from({ length: size }, async () => {
    while (next < items.length) {
      const i = next++;
      out[i] = await fn(items[i]);
    }
  }));
  return out;
}

async function measureSavings(): Promise<Saving[]> {
  const settingsFile = `${Deno.env.get("HOME")}/.claude/settings.json`;
  const user = JSON.parse(await Deno.readTextFile(settingsFile));
  const short = (v: unknown) => (typeof v === "object" ? "" : `: ${JSON.stringify(v)}`);
  const savers = [
    ...Object.entries(user).filter(([k]) => k !== "permissions")
      .map(([k, v]) => ({ label: k + short(v), settings: { [k]: v } })),
    // Only plain tool names remove a tool; command patterns like Bash(...) just block commands
    ...((user.permissions?.deny ?? []) as string[]).filter((t) => !t.includes("("))
      .map((t) => ({ label: `deny ${t}`, settings: { permissions: { deny: [t] } } })),
  ];
  const jobs = models.flatMap((model) => [null, ...savers].map((saver) => ({ model, saver })));
  const totals = await pool(jobs, 8, async ({ model, saver }) => {
    const extra = saver ? ["--settings", JSON.stringify(saver.settings)] : [];
    const raw = await $`claude -p /context --model ${model} --setting-sources ${""} ${extra}`.stdin("null").noThrow()
      .stderr("piped").text();
    return totalTokens(parse(raw));
  });
  const base = Object.fromEntries(models.map((m) => [m, totals[jobs.findIndex((j) => j.model === m && !j.saver)]]));
  return savers.map((saver) => ({
    label: saver.label,
    deltas: Object.fromEntries(models.map((m) => [m, base[m] - totals[jobs.findIndex((j) => j.model === m && j.saver === saver)]])),
  }));
}

const savings = Deno.args.includes("--savings") ? await measureSavings() : undefined;

const categories = [...new Set(results.flatMap((r) => [...r.categories.keys()]))];
const sections = counted.filter((s) => results.some((r) => r.counts.has(s)));
const header = ["", "Total", ...categories, ...sections.map((s) => `# ${s}`)];
const rows = results.map((r) => [
  r.label,
  r.total,
  ...categories.map((c) => r.categories.get(c) ?? "-"),
  ...sections.map((s) => String(r.counts.get(s) ?? 0)),
]);

const widths = header.map((h, i) => Math.max(h.length, ...rows.map((r) => r[i].length)));
const fmt = (r: string[]) => r.map((c, i) => (i === 0 ? c.padEnd(widths[i]) : c.padStart(widths[i]))).join("  ");
console.log(fmt(header));
console.log(widths.map((w) => "-".repeat(w)).join("  "));
rows.forEach((r, i) => {
  if (i > 0 && i % Object.keys(variants).length === 0) console.log();
  console.log(fmt(r));
});

if (costs) {
  const usd = (c?: Call) => (c ? `$${c.cost.toFixed(4)}` : "-");
  const tok = (c?: Call) => (c ? `${c.input} (w ${c.cacheWrite} / r ${c.cacheRead})` : "-");
  const cHeader = ['"hi" price', "1st call", "input tokens", "repeat", "input tokens"];
  const cRows = results.map((r, i) => {
    const c = costs[i];
    return c.error ? [r.label, `n/a: ${c.error}`, "", "", ""] : [r.label, usd(c.first), tok(c.first), usd(c.repeat), tok(c.repeat)];
  });
  const w = cHeader.map((h, i) => Math.max(h.length, ...cRows.map((r) => (r[1].startsWith("n/a") ? 0 : r[i].length))));
  const f = (r: string[]) => r.map((c, i) => (i === 0 ? c.padEnd(w[i]) : c.padStart(w[i]))).join("  ").trimEnd();
  console.log("\n" + f(cHeader));
  console.log(w.map((n) => "-".repeat(n)).join("  "));
  cRows.forEach((r, i) => {
    if (i > 0 && i % Object.keys(variants).length === 0) console.log();
    console.log(r[1].startsWith("n/a") ? `${r[0].padEnd(w[0])}  ${r[1]}` : f(r));
  });
}

if (Deno.args.includes("--raw")) {
  for (const r of results) console.log(`\n===== ${r.label} =====\n${r.raw}`);
}

// Positive = tokens saved, negative = tokens added; hide anything below the /context rounding noise
const relevantSavings = savings
  ?.filter((s) => Object.values(s.deltas).some((d) => Math.abs(d) > 100))
  .sort((a, b) => sum(b.deltas) - sum(a.deltas));

function sum(d: Record<string, number>): number {
  return Object.values(d).reduce((a, b) => a + b, 0);
}

if (relevantSavings) {
  const sHeader = ["Saved by setting", ...models];
  const sRows = relevantSavings.map((s) => [s.label, ...models.map((m) => String(s.deltas[m]))]);
  const w = sHeader.map((h, i) => Math.max(h.length, ...sRows.map((r) => r[i].length)));
  const f = (r: string[]) => r.map((c, i) => (i === 0 ? c.padEnd(w[i]) : c.padStart(w[i]))).join("  ");
  console.log("\n" + f(sHeader));
  console.log(w.map((n) => "-".repeat(n)).join("  "));
  sRows.forEach((r) => console.log(f(r)));
}

const htmlIdx = Deno.args.indexOf("--html");
if (htmlIdx !== -1) {
  const next = Deno.args[htmlIdx + 1];
  const file = next && !next.startsWith("--") ? next : "/tmp/claude-context-compare.html";
  const data = runs.map((r, i) => ({
    model: r.model,
    modelId: results[i].modelId,
    variant: r.variant,
    command: r.command,
    hiCommand: r.hiCommand,
    cost: costs?.[i],
    categories: Object.fromEntries([...results[i].categories].map(([k, v]) => [k, toTokens(v)])),
  }));
  await Deno.writeTextFile(file, renderHtml(data, variants, relevantSavings));
  console.log(`\nChart: ${file}`);
  await $`xdg-open ${file}`.noThrow().quiet();
}

function toTokens(s: string): number {
  const m = s.match(/^([\d.]+)\s*([km]?)$/i);
  if (!m) return 0;
  return Math.round(parseFloat(m[1]) * ({ k: 1e3, m: 1e6 }[m[2].toLowerCase()] ?? 1));
}

function shell(args: string[]): string {
  return ["claude", ...args].map((a) => (/^[\w./-]+$/.test(a) ? a : `"${a}"`)).join(" ");
}

type Row = { model: string; modelId: string; variant: string; command: string; hiCommand: string; cost?: Cost; categories: Record<string, number> };

function renderHtml(data: Row[], variantInfo: typeof variants, savings: Saving[] | undefined): string {
  const json = JSON.stringify({ data, variantInfo, savings, date: new Date().toISOString().slice(0, 10) }).replace(/</g, "\\u003c");
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Claude Code startup context</title>
<style>
.viz-root {
  color-scheme: light;
  --page: #f9f9f7; --surface-1: #fcfcfb;
  --text-primary: #0b0b0b; --text-secondary: #52514e; --text-muted: #898781;
  --grid: #e1e0d9; --axis: #c3c2b7; --border: rgba(11,11,11,0.10);
  --series-1: #2a78d6; --series-2: #eb6834; --series-3: #1baf7a; --series-4: #eda100; --series-5: #e87ba4;
}
@media (prefers-color-scheme: dark) {
  :root:where(:not([data-theme="light"])) .viz-root {
    color-scheme: dark;
    --page: #0d0d0d; --surface-1: #1a1a19;
    --text-primary: #ffffff; --text-secondary: #c3c2b7; --text-muted: #898781;
    --grid: #2c2c2a; --axis: #383835; --border: rgba(255,255,255,0.10);
    --series-1: #3987e5; --series-2: #d95926; --series-3: #199e70; --series-4: #c98500; --series-5: #d55181;
  }
}
:root[data-theme="dark"] .viz-root {
  color-scheme: dark;
  --page: #0d0d0d; --surface-1: #1a1a19;
  --text-primary: #ffffff; --text-secondary: #c3c2b7; --text-muted: #898781;
  --grid: #2c2c2a; --axis: #383835; --border: rgba(255,255,255,0.10);
  --series-1: #3987e5; --series-2: #d95926; --series-3: #199e70; --series-4: #c98500; --series-5: #d55181;
}
html, body { margin: 0; }
.viz-root {
  min-height: 100vh; background: var(--page); color: var(--text-primary);
  font: 14px/1.4 system-ui, -apple-system, "Segoe UI", sans-serif; padding: 32px 16px;
  box-sizing: border-box;
}
.card {
  max-width: 960px; margin: 0 auto; background: var(--surface-1); border: 1px solid var(--border);
  border-radius: 12px; padding: 24px 24px 16px;
}
h1 { font-size: 18px; font-weight: 600; margin: 0 0 4px; }
.sub { color: var(--text-secondary); margin: 0 0 16px; }
.controls { display: flex; flex-wrap: wrap; gap: 16px; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.legend { display: flex; flex-wrap: wrap; gap: 4px 16px; color: var(--text-secondary); font-size: 13px; }
.legend span { display: inline-flex; align-items: center; gap: 6px; }
.legend i { width: 10px; height: 10px; border-radius: 3px; display: inline-block; }
.toggle { display: inline-flex; border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }
.toggle button {
  font: inherit; font-size: 13px; background: none; border: 0; padding: 4px 12px; color: var(--text-secondary); cursor: pointer;
}
.toggle button[aria-pressed="true"] { background: var(--grid); color: var(--text-primary); }
svg { display: block; width: 100%; height: auto; overflow: visible; }
svg text { fill: var(--text-secondary); font-size: 12px; }
svg .model { paint-order: stroke; stroke: var(--surface-1); stroke-width: 6px; stroke-linejoin: round; fill: var(--text-primary); font-weight: 600; font-size: 13px; }
svg .model-id { fill: var(--text-muted); font-weight: 400; font-size: 12px; font-family: ui-monospace, monospace; }
svg .total { fill: var(--text-primary); font-variant-numeric: tabular-nums; }
svg .tick { fill: var(--text-muted); font-size: 11px; font-variant-numeric: tabular-nums; }
table { width: 100%; border-collapse: collapse; font-size: 13px; font-variant-numeric: tabular-nums; }
th, td { padding: 6px 8px; text-align: right; border-bottom: 1px solid var(--grid); }
th:first-child, td:first-child, th:nth-child(2), td:nth-child(2) { text-align: left; }
th { color: var(--text-secondary); font-weight: 500; }
.card + .card { margin-top: 24px; }
.viz-root { --cost-1: #1c5cab; --cost-2: #86b6ef; --save: #2a78d6; --add: #e34948; }
:root[data-theme="dark"] .viz-root { --save: #3987e5; --add: #e66767; }
@media (prefers-color-scheme: dark) { :root:where(:not([data-theme="light"])) .viz-root { --save: #3987e5; --add: #e66767; } }
svg .panel { fill: var(--text-primary); font-weight: 600; font-size: 13px; }
svg .val { font-size: 11px; font-variant-numeric: tabular-nums; }
svg .setting { font-family: ui-monospace, monospace; font-size: 12px; fill: var(--text-primary); }
:root[data-theme="dark"] .viz-root { --cost-1: #5598e7; --cost-2: #184f95; }
@media (prefers-color-scheme: dark) { :root:where(:not([data-theme="light"])) .viz-root { --cost-1: #5598e7; --cost-2: #184f95; } }
svg .na { fill: var(--text-muted); font-style: italic; }
.note { color: var(--text-muted); font-size: 12px; margin: 12px 0 0; }
.variants { display: grid; grid-template-columns: max-content 1fr; gap: 6px 16px; margin: 20px 0 0; padding-top: 16px; border-top: 1px solid var(--grid); font-size: 13px; }
.variants dt { font-weight: 600; }
.variants dd { margin: 0; color: var(--text-secondary); }
.variants code { display: block; color: var(--text-muted); font-size: 12px; margin-top: 2px; }
code { font-family: ui-monospace, monospace; }
[hidden] { display: none !important; }
</style>
</head>
<body>
<div class="viz-root">
  <div class="card">
    <h1>Claude Code startup context by model and settings</h1>
    <p class="sub">Tokens in the context window before the first message, from <code>claude -p /context</code></p>
    <div class="controls">
      <div class="legend" id="legend"></div>
      <div class="toggle" role="group" aria-label="View">
        <button id="btnChart" aria-pressed="true">Chart</button>
        <button id="btnTable" aria-pressed="false">Table</button>
      </div>
    </div>
    <div id="chart"></div>
    <div id="table" hidden></div>
    <dl class="variants" id="variants"></dl>
    <p class="note" id="note"></p>
  </div>
  <div class="card" id="savingsCard" hidden>
    <h1>What each setting saves</h1>
    <p class="sub">Tokens removed from the startup context by adding one setting from the user <code>settings.json</code> to a run with no settings: <code>claude -p /context --setting-sources "" --settings '{…}'</code></p>
    <div class="controls">
      <div class="legend">
        <span><i style="background:var(--save)"></i>Saves tokens</span>
        <span id="addsLegend"><i style="background:var(--add)"></i>Adds tokens</span>
      </div>
    </div>
    <div id="savingsChart"></div>
    <p class="note">Settings that change 100 tokens or less (the /context rounding step) are left out.</p>
  </div>
  <div class="card" id="costCard" hidden>
    <h1>Price of the simplest request</h1>
    <p class="sub">API list price of <code>claude -p hi</code>, sent twice per configuration: the first call writes the prompt cache, the repeat reads it</p>
    <div class="controls">
      <div class="legend">
        <span><i style="background:var(--cost-1)"></i>1st call</span>
        <span><i style="background:var(--cost-2)"></i>Repeat (cached)</span>
      </div>
    </div>
    <div id="costChart"></div>
    <p class="note">Input includes everything Claude Code adds at runtime (environment, git status, …), so it is larger than the /context numbers above. Each run appends a random nonce to the system prompt so the first call never reuses an older cache.</p>
  </div>
</div>
<script>
const { data, variantInfo, savings, date } = ${json};
const series = [
  { key: "System prompt", label: "System prompt" },
  { key: "System tools", label: "System tools" },
  { key: "Memory files", label: "Memory files" },
  { key: "Skills", label: "Skills" },
  { key: "Other", label: "Agents & messages" },
];
series.forEach((s, i) => (s.color = "var(--series-" + (i + 1) + ")"));
const rows = data.map((d) => {
  const c = d.categories;
  const v = {
    "System prompt": c["System prompt"] || 0,
    "System tools": c["System tools"] || 0,
    "Memory files": c["Memory files"] || 0,
    "Skills": c["Skills"] || 0,
    "Other": Object.entries(c)
      .filter(([k]) => !["System prompt", "System tools", "Memory files", "Skills"].includes(k))
      .reduce((a, [, n]) => a + n, 0),
  };
  return { ...d, v, total: Object.values(v).reduce((a, b) => a + b, 0) };
});
const fmt = (n) => (n >= 1000 ? (n / 1000).toFixed(1).replace(/\\.0$/, "") + "k" : String(n));

document.getElementById("legend").innerHTML = series
  .map((s) => '<span><i style="background:' + s.color + '"></i>' + s.label + "</span>").join("");
const esc = (s) => s.replace(/[&<>"']/g, (c) => "&#" + c.charCodeAt(0) + ";");
document.getElementById("variants").innerHTML = Object.entries(variantInfo).map(([name, v]) => {
  const cmd = rows.find((r) => r.variant === name).command.replace(/--model \\S+/, "--model <model>");
  return "<dt>" + esc(name) + "</dt><dd>" + esc(v.desc) + "<code>" + esc(cmd) + "</code></dd>";
}).join("");
document.getElementById("note").textContent =
  "Deferred tools, compact buffer and free space are left out: they don't take up context. Generated " + date + ".";

// ---------- chart ----------
const W = 900, labelW = 200, totalW = 56, rowH = 30, barH = 18, groupGap = 18, headH = 24, axisH = 28, gap = 2;
const models = [...new Set(rows.map((r) => r.model))];
const max = Math.max(...rows.map((r) => r.total));
const step = max > 20000 ? 5000 : max > 8000 ? 2000 : 1000;
const xMax = Math.ceil(max / step) * step;
const plotW = W - labelW - totalW;
const x = (n) => labelW + (n / xMax) * plotW;
let y = 0;
const layout = [];
for (const m of models) {
  layout.push({ type: "head", model: m, modelId: rows.find((r) => r.model === m).modelId, y });
  y += headH;
  for (const r of rows.filter((r) => r.model === m)) {
    layout.push({ type: "row", r, y });
    y += rowH;
  }
  y += groupGap;
}
const plotH = y - groupGap;
const H = plotH + axisH;
let svg = '<svg viewBox="0 0 ' + W + " " + H + '" role="img" aria-label="Stacked bar chart of startup context tokens">';
for (let t = 0; t <= xMax; t += step) {
  svg += '<line x1="' + x(t) + '" x2="' + x(t) + '" y1="0" y2="' + plotH + '" stroke="' + (t === 0 ? "var(--axis)" : "var(--grid)") + '" stroke-width="1"/>';
  svg += '<text class="tick" x="' + x(t) + '" y="' + (plotH + 18) + '" text-anchor="middle">' + fmt(t) + "</text>";
}
const endRounded = (x0, y0, w, h, r) => {
  r = Math.min(r, w, h / 2);
  return "M" + x0 + "," + y0 + "h" + (w - r) + "a" + r + "," + r + " 0 0 1 " + r + "," + r + "v" + (h - 2 * r) +
    "a" + r + "," + r + " 0 0 1 " + -r + "," + r + "h" + (r - w) + "z";
};
layout.forEach((l, li) => {
  if (l.type === "head") {
    svg += '<text class="model" x="0" y="' + (l.y + 16) + '">' + l.model +
      '<tspan class="model-id" dx="8">' + l.modelId + "</tspan></text>";
    return;
  }
  const r = l.r, by = l.y + (rowH - barH) / 2;
  svg += '<g class="row" data-i="' + li + '">';
  svg += '<text x="12" y="' + (by + barH / 2 + 4) + '">' + r.variant + "</text>";
  let acc = 0;
  const segs = series.map((s) => ({ s, n: r.v[s.key] })).filter((d) => d.n > 0);
  segs.forEach((d, si) => {
    const x0 = x(acc) + (si > 0 ? gap / 2 : 0);
    acc += d.n;
    const x1 = x(acc) - (si < segs.length - 1 ? gap / 2 : 0);
    const w = Math.max(x1 - x0, 1);
    const last = si === segs.length - 1;
    const shape = last
      ? '<path class="seg" data-k="' + d.s.key + '" d="' + endRounded(x0, by, w, barH, 4) + '" fill="' + d.s.color + '"/>'
      : '<rect class="seg" data-k="' + d.s.key + '" x="' + x0 + '" y="' + by + '" width="' + w + '" height="' + barH + '" fill="' + d.s.color + '"/>';
    svg += shape;
  });
  svg += '<text class="total" x="' + (x(r.total) + 8) + '" y="' + (by + barH / 2 + 4) + '">' + fmt(r.total) + "</text>";
  svg += "</g>";
});
svg += "</svg>";
document.getElementById("chart").innerHTML = svg;

// ---------- cost chart ----------
const costRows = rows.filter((r) => r.cost);
if (costRows.length) {
  document.getElementById("costCard").hidden = false;
  const usd = (n) => "$" + (n < 0.01 ? n.toFixed(4) : n.toFixed(3));
  const cMax = Math.max(...costRows.flatMap((r) => [r.cost.first?.cost ?? 0, r.cost.repeat?.cost ?? 0]));
  const cStep = [0.005, 0.01, 0.02, 0.025, 0.05, 0.1].find((s) => cMax / s <= 6) ?? 0.2;
  const cxMax = Math.ceil(cMax / cStep) * cStep;
  const cx = (n) => labelW + (n / cxMax) * plotW;
  const cRowH = 34, cBarH = 10;
  let cy = 0;
  const cLayout = [];
  for (const m of models) {
    cLayout.push({ type: "head", model: m, modelId: rows.find((r) => r.model === m).modelId, y: cy });
    cy += headH;
    for (const r of costRows.filter((r) => r.model === m)) {
      cLayout.push({ type: "row", r, y: cy });
      cy += cRowH;
    }
    cy += groupGap;
  }
  const cPlotH = cy - groupGap;
  let c = '<svg viewBox="0 0 ' + W + " " + (cPlotH + axisH) + '" role="img" aria-label="Price of a hi request">';
  for (let t = 0; t <= cxMax + 1e-9; t += cStep) {
    c += '<line x1="' + cx(t) + '" x2="' + cx(t) + '" y1="0" y2="' + cPlotH + '" stroke="' + (t === 0 ? "var(--axis)" : "var(--grid)") + '"/>';
    c += '<text class="tick" x="' + cx(t) + '" y="' + (cPlotH + 18) + '" text-anchor="middle">$' + +t.toFixed(3) + "</text>";
  }
  cLayout.forEach((l, li) => {
    if (l.type === "head") {
      c += '<text class="model" x="0" y="' + (l.y + 16) + '">' + l.model + '<tspan class="model-id" dx="8">' + l.modelId + "</tspan></text>";
      return;
    }
    const r = l.r, top = l.y + (cRowH - 2 * cBarH - gap) / 2;
    c += '<g class="row" data-i="' + li + '"><text x="12" y="' + (l.y + cRowH / 2 + 4) + '">' + r.variant + "</text>";
    if (r.cost.error) {
      c += '<text class="na" x="' + (labelW + 8) + '" y="' + (l.y + cRowH / 2 + 4) + '">n/a: ' + esc(r.cost.error) + "</text>";
    } else {
      [["first", "var(--cost-1)"], ["repeat", "var(--cost-2)"]].forEach(([k, color], bi) => {
        const n = r.cost[k].cost, by = top + bi * (cBarH + gap);
        c += '<path class="seg" d="' + endRounded(labelW, by, Math.max(cx(n) - labelW, 1), cBarH, 4) + '" fill="' + color + '"/>';
        c += '<text class="total" x="' + (cx(n) + 6) + '" y="' + (by + cBarH - 1) + '" style="font-size:11px">' + usd(n) + "</text>";
      });
    }
    c += "</g>";
  });
  c += "</svg>";
  const costChart = document.getElementById("costChart");
  costChart.innerHTML = c;
}

// ---------- savings chart (small multiples, one panel per model) ----------
if (savings?.length) {
  document.getElementById("savingsCard").hidden = false;
  document.getElementById("addsLegend").hidden = !savings.some((s) => Object.values(s.deltas).some((d) => d < -100));
  const sLabelW = 280, panelGap = 24, sRowH = 24, sBarH = 12, sHead = 26;
  const panelW = (W - sLabelW - panelGap * (models.length - 1)) / models.length;
  const all = savings.flatMap((s) => Object.values(s.deltas));
  const lo = Math.min(0, ...all), hi = Math.max(0, ...all);
  // leave room for the value labels at both ends
  const pad = 44;
  const sx = (px, n) => px + pad + ((n - lo) / (hi - lo || 1)) * (panelW - 2 * pad);
  const sH = sHead + savings.length * sRowH;
  let c = '<svg viewBox="0 0 ' + W + " " + sH + '" role="img" aria-label="Tokens saved per setting and model">';
  models.forEach((m, mi) => {
    const px = sLabelW + mi * (panelW + panelGap);
    const modelId = rows.find((r) => r.model === m).modelId;
    c += '<text class="panel" x="' + sx(px, 0) + '" y="16" text-anchor="middle">' + m + '<tspan class="model-id" dx="6">' + modelId + "</tspan></text>";
  });
  savings.forEach((s, si) => {
    const y = sHead + si * sRowH, by = y + (sRowH - sBarH) / 2;
    if (si % 2 === 1) c += '<rect x="0" y="' + y + '" width="' + W + '" height="' + sRowH + '" fill="var(--grid)" opacity="0.35"/>';
    c += '<text class="setting" x="0" y="' + (by + sBarH - 1) + '">' + esc(s.label) + "</text>";
  });
  models.forEach((m, mi) => {
    const px = sLabelW + mi * (panelW + panelGap);
    c += '<line x1="' + sx(px, 0) + '" x2="' + sx(px, 0) + '" y1="' + (sHead - 4) + '" y2="' + sH + '" stroke="var(--axis)"/>';
  });
  savings.forEach((s, si) => {
    const by = sHead + si * sRowH + (sRowH - sBarH) / 2;
    models.forEach((m, mi) => {
      const px = sLabelW + mi * (panelW + panelGap);
      const d = s.deltas[m], x0 = sx(px, 0), x1 = sx(px, d);
      if (Math.abs(d) < 100) {
        c += '<text class="val tick" x="' + (x0 + 6) + '" y="' + (by + sBarH - 1) + '">0</text>';
        return;
      }
      const left = Math.min(x0, x1), w = Math.max(Math.abs(x1 - x0), 1);
      // round only the data end, square at the zero baseline
      const shape = d > 0
        ? endRounded(left, by, w, sBarH, 4)
        : "M" + (left + w) + "," + by + "h" + -(w - 4) + "a4,4 0 0 0 -4,4v" + (sBarH - 8) + "a4,4 0 0 0 4,4h" + (w - 4) + "z";
      c += '<path d="' + shape + '" fill="' + (d > 0 ? "var(--save)" : "var(--add)") + '"/>';
      const label = (d > 0 ? "" : "+") + fmt(Math.abs(d));
      c += d > 0
        ? '<text class="val" x="' + (x1 + 4) + '" y="' + (by + sBarH - 1) + '">' + label + "</text>"
        : '<text class="val" x="' + (x1 - 4) + '" y="' + (by + sBarH - 1) + '" text-anchor="end">' + label + "</text>";
    });
  });
  c += "</svg>";
  document.getElementById("savingsChart").innerHTML = c;
}

// ---------- table ----------
document.getElementById("table").innerHTML = "<table><thead><tr><th>Model</th><th>Settings</th>" +
  series.map((s) => "<th>" + s.label + "</th>").join("") + "<th>Total</th>" +
  (costRows.length ? '<th>"hi" 1st</th><th>"hi" repeat</th>' : "") + "</tr></thead><tbody>" +
  rows.map((r) => "<tr><td>" + r.modelId + '</td><td title="' + esc(r.command) + '">' + r.variant + "</td>" +
    series.map((s) => "<td>" + (r.v[s.key] ? r.v[s.key].toLocaleString("en") : "–") + "</td>").join("") +
    "<td><b>" + r.total.toLocaleString("en") + "</b></td>" +
    (costRows.length ? (r.cost?.first ? "<td>$" + r.cost.first.cost.toFixed(4) + "</td><td>$" + r.cost.repeat.cost.toFixed(4) + "</td>" : "<td>–</td><td>–</td>") : "") +
    "</tr>").join("") + "</tbody></table>";
const btnChart = document.getElementById("btnChart"), btnTable = document.getElementById("btnTable");
const show = (table) => {
  document.getElementById("chart").hidden = table;
  document.getElementById("legend").style.visibility = table ? "hidden" : "visible";
  document.getElementById("table").hidden = !table;
  btnChart.setAttribute("aria-pressed", String(!table));
  btnTable.setAttribute("aria-pressed", String(table));
};
btnChart.onclick = () => show(false);
btnTable.onclick = () => show(true);
</script>
</body>
</html>
`;
}
