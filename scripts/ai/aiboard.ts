#!/usr/bin/env -S deno run --allow-run --allow-env --allow-read --allow-net
// Live dashboard for .aiwork implementation sessions: kanban board of tickets
// plus the implementation-notes log, self-updating via file watcher + SSE.
//
// Usage: aiboard [project-dir ...] [--port 4517] [--no-open]
// Default project dir is the cwd. Each dir must contain an .aiwork/ folder.
import $ from "jsr:@david/dax";
import { marked } from "npm:marked@15";

// ---------- CLI ----------

const args = [...Deno.args];
let port = 4517;
let open = true;
const roots: string[] = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--port") port = Number(args[++i]);
  else if (args[i] === "--no-open") open = false;
  else if (args[i] === "--help" || args[i] === "-h") {
    $.log("Usage: aiboard [project-dir ...] [--port N] [--no-open]");
    Deno.exit(0);
  } else roots.push(args[i]);
}
if (roots.length === 0) roots.push(Deno.cwd());

const projects = roots.map((r) => {
  const root = $.path(r).resolve();
  return { root, aiwork: root.join(".aiwork") };
});

for (const p of projects) {
  if (!p.aiwork.isDirSync()) {
    $.logWarn(`${p.root}: no .aiwork/ folder (will appear once created)`);
  }
}

// ---------- Scanning ----------

interface Ticket {
  file: string;
  num: string;
  title: string;
  status: string; // ready | in-progress | done
  blockedBy: string[];
  blocked: boolean; // ready but blockers unmet
  criteriaDone: number;
  criteriaTotal: number;
}

interface TaskFolder {
  name: string;
  docs: string[]; // top-level .md/.html artifacts, servable via /f/
  tickets: Ticket[];
  notes: string | null; // pre-rendered HTML of the notes tail
  notesFile: string | null;
  hasReview: boolean;
  mtime: number;
  running: boolean; // a ticket is in progress, or the folder was just touched
  expanded: boolean; // unfinished work to show — gets a full board section
  planned: boolean; // has a tickets/ folder with tickets
  docStatus: string | null; // raw frontmatter status of spec.md / plan*.md
  // The one axis the board is organized by: from the tickets when there are
  // any, otherwise from the spec/plan frontmatter.
  state: DocState;
  blockedReason: string | null;
  docCriteriaDone: number;
  docCriteriaTotal: number;
}

interface Project {
  root: string;
  name: string;
  tasks: TaskFolder[];
}

const escHtml = (s: string) =>
  s.replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c] as string));

// GFM markdown via marked; HTML comments render as muted asides
const renderer = new marked.Renderer();
renderer.html = ({ text }: { text: string }) => {
  const m = text.trim().match(/^<!--([\s\S]*?)-->$/);
  return m ? `<div class="md-comment">${escHtml(m[1].trim())}</div>` : text;
};
marked.use({ renderer, gfm: true, breaks: true });
const mdToHtml = (src: string) => marked.parse(src, { async: false }) as string;

function parseFrontmatter(text: string): Record<string, string> {
  const m = text.match(/^---\n([\s\S]*?)\n---/);
  const out: Record<string, string> = {};
  if (!m) return out;
  for (const line of m[1].split("\n")) {
    const kv = line.match(/^(\w[\w-]*):\s*(.*)$/);
    if (kv) out[kv[1]] = kv[2].replace(/#.*$/, "").trim();
  }
  return out;
}

// Lifecycle of a spec/plan-level task, from its `status:` frontmatter. Older
// artifacts use a looser vocabulary, so the aliases map onto the same states.
// "unknown" is its own state, not a synonym for not-started: tickets exist only
// where a task was worth splitting up, so a folder without them says nothing
// about whether the work has been done.
type DocState =
  | "unknown"
  | "not-started"
  | "in-progress"
  | "blocked"
  | "done"
  | "abandoned";

const DOC_STATES: Record<string, DocState> = {
  draft: "not-started",
  planned: "not-started",
  todo: "not-started",
  "in-progress": "in-progress",
  active: "in-progress",
  wip: "in-progress",
  started: "in-progress",
  blocked: "blocked",
  waiting: "blocked",
  done: "done",
  complete: "done",
  completed: "done",
  shipped: "done",
  abandoned: "abandoned",
  dropped: "abandoned",
  cancelled: "abandoned",
  canceled: "abandoned",
  wontfix: "abandoned",
  superseded: "abandoned",
};

// An unrecognized word is as uninformative as no word at all.
const docState = (raw: string | null): DocState =>
  DOC_STATES[(raw ?? "").toLowerCase()] ?? "unknown";

// Same vocabulary, read off a ticket pile: any work touched at all counts as
// started, and a pile whose every remaining ticket waits on another is blocked.
function ticketState(tickets: Ticket[]): DocState {
  if (tickets.every((t) => t.status === "done")) return "done";
  if (tickets.some((t) => t.status === "in-progress")) return "in-progress";
  const open = tickets.filter((t) => t.status !== "done");
  if (open.every((t) => t.blocked)) return "blocked";
  return tickets.some((t) => t.status === "done") ? "in-progress" : "not-started";
}

async function scanTask(dir: ReturnType<typeof $.path>): Promise<TaskFolder> {
  let mtime = (await dir.stat())?.mtime?.getTime() ?? 0;
  const tickets: Ticket[] = [];
  const ticketsDir = dir.join("tickets");
  if (ticketsDir.isDirSync()) {
    for await (const e of Deno.readDir(ticketsDir.toString())) {
      if (!e.isFile || !e.name.endsWith(".md")) continue;
      const path = ticketsDir.join(e.name);
      const text = await path.readText();
      const fm = parseFrontmatter(text);
      const heading = text.match(/^# (.+)$/m)?.[1] ?? e.name.replace(/\.md$/, "");
      tickets.push({
        file: e.name,
        num: e.name.match(/^(\d+)/)?.[1] ?? "",
        title: heading.replace(/^\d+\s*[—-]\s*/, ""),
        status: fm.status || "ready",
        blockedBy: (fm.blocked_by?.match(/[\w-]+/g) ?? []),
        blocked: false,
        criteriaDone: (text.match(/^- \[x\]/gim) ?? []).length,
        criteriaTotal: (text.match(/^- \[[ x]\]/gim) ?? []).length,
      });
      mtime = Math.max(mtime, (await path.stat())?.mtime?.getTime() ?? 0);
    }
  }
  tickets.sort((a, b) => a.file.localeCompare(b.file));
  const byNum = new Map(tickets.map((t) => [t.num, t]));
  for (const t of tickets) {
    t.blocked = t.status === "ready" &&
      t.blockedBy.some((n) => byNum.get(n)?.status !== "done");
  }

  let notes: string | null = null;
  let notesFile: string | null = null;
  for (const name of ["implementation-notes.md", "notes.md"]) {
    const f = dir.join(name);
    if (f.isFileSync()) {
      notes = await f.readText();
      notesFile = name;
      mtime = Math.max(mtime, (await f.stat())?.mtime?.getTime() ?? 0);
      break;
    }
  }

  const entries = [...Deno.readDirSync(dir.toString())];
  const hasReview = entries.some((e) => /^review(_\d+)?\.md$/.test(e.name));
  const docs = entries
    .filter((e) => e.isFile && /\.(md|html)$/.test(e.name))
    .map((e) => e.name)
    .sort();

  // Spec/plan docs are the only progress signal a ticketless folder has:
  // a frontmatter status and whatever checklist the spec carries.
  let docStatus: string | null = null;
  let blockedReason: string | null = null;
  let docCriteriaDone = 0;
  let docCriteriaTotal = 0;
  const docRank = (n: string) =>
    n === "spec.md" ? 0 : /^plan/.test(n) ? 1 : 2;
  for (const name of docs.filter((d) => d.endsWith(".md")).sort(
    (a, b) => docRank(a) - docRank(b) || a.localeCompare(b),
  )) {
    const text = await dir.join(name).readText();
    const fm = parseFrontmatter(text);
    docStatus ??= fm.status || null;
    blockedReason ??= fm.blocked_by || fm.blocked_reason || null;
    docCriteriaDone += (text.match(/^- \[x\]/gim) ?? []).length;
    docCriteriaTotal += (text.match(/^- \[[ x]\]/gim) ?? []).length;
  }

  const planned = tickets.length > 0;
  const running = tickets.some((t) => t.status === "in-progress") ||
    Date.now() - mtime < 15 * 60 * 1000;
  // Tickets are the better evidence when they exist, but only frontmatter can
  // say a task was abandoned, so that verdict wins over any ticket pile.
  // Tickets are hard evidence; frontmatter only fills in what they can't say —
  // that a task was abandoned, or (with no tickets at all) anything whatsoever.
  const fromDoc = docState(docStatus);
  const state = planned && fromDoc !== "abandoned"
    ? ticketState(tickets)
    : fromDoc;
  // A task nobody is working on shows as a row, not a board — no notes needed.
  const expanded = running || (planned && state !== "done");
  if (!expanded) notes = null;
  else if (notes) notes = mdToHtml(notes.split("\n").slice(-150).join("\n"));

  return {
    name: dir.basename(), docs, tickets, notes, notesFile, hasReview, mtime,
    running, expanded, planned, docStatus, state,
    blockedReason, docCriteriaDone, docCriteriaTotal,
  };
}

async function scan(): Promise<Project[]> {
  const out: Project[] = [];
  for (const p of projects) {
    const tasks: TaskFolder[] = [];
    if (p.aiwork.isDirSync()) {
      for await (const e of Deno.readDir(p.aiwork.toString())) {
        if (e.isDirectory) tasks.push(await scanTask(p.aiwork.join(e.name)));
      }
    }
    tasks.sort((a, b) => b.mtime - a.mtime);
    out.push({ root: p.root.toString(), name: p.root.basename(), tasks });
  }
  return out;
}

// ---------- Watcher + SSE ----------

const clients = new Set<ReadableStreamDefaultController<Uint8Array>>();
const enc = new TextEncoder();

async function broadcast() {
  const payload = `data: ${JSON.stringify(await scan())}\n\n`;
  for (const c of clients) {
    try {
      c.enqueue(enc.encode(payload));
    } catch {
      clients.delete(c);
    }
  }
}

let debounce: ReturnType<typeof setTimeout> | undefined;
function watch(dir: string) {
  (async () => {
    try {
      for await (const _ of Deno.watchFs(dir, { recursive: true })) {
        clearTimeout(debounce);
        debounce = setTimeout(broadcast, 250);
      }
    } catch {
      // dir vanished; retry via the poll below
    }
  })();
}

const watched = new Set<string>();
setInterval(() => {
  // pick up .aiwork folders created after startup
  for (const p of projects) {
    const d = p.aiwork.toString();
    if (!watched.has(d) && p.aiwork.isDirSync()) {
      watched.add(d);
      watch(d);
      broadcast();
    }
  }
}, 3000);
for (const p of projects) {
  if (p.aiwork.isDirSync()) {
    watched.add(p.aiwork.toString());
    watch(p.aiwork.toString());
  }
}

// ---------- Server ----------

// frontmatter block -> key/value rows (unparseable lines shown verbatim)
function fmToHtml(yaml: string): string {
  const rows = yaml.split("\n").filter((l) => l.trim()).map((line) => {
    const kv = line.match(/^(\w[\w-]*):\s*(.*)$/);
    return kv
      ? `<div class="fm-row"><span class="fm-key">${escHtml(kv[1])}</span><span>${escHtml(kv[2])}</span></div>`
      : `<div class="fm-row">${escHtml(line)}</div>`;
  });
  return `<div class="frontmatter">${rows.join("")}</div>`;
}

const mermaidStyles = `
  .mermaid { margin: 0 0 14px; overflow-x: auto; text-align: center; cursor: zoom-in; }
  .mermaid svg { max-width: 100%; height: auto; }
  .mermaid.zoom { position: fixed; inset: 0; z-index: 99; margin: 0; padding: 24px;
                  background: var(--surface); overflow: auto; cursor: zoom-out; }
  .mermaid.zoom svg { max-width: none; }`;

const mermaidScript = `<script>
// mermaid fences become diagrams; cached so repeat renders don't flicker
const mmdCache = new Map();
let mmdLib = null;
let mmdSeq = 0;

async function drawMermaid() {
  const blocks = [...document.querySelectorAll("code.language-mermaid")];
  if (!blocks.length) return;
  const swap = (code, svg) => {
    const box = document.createElement("div");
    box.className = "mermaid";
    box.innerHTML = svg;
    code.closest("pre").replaceWith(box);
  };
  const pending = [];
  for (const code of blocks) {
    const src = code.textContent;
    const hit = mmdCache.get(src);
    if (hit) swap(code, hit);
    else pending.push([code, src]);
  }
  if (!pending.length) return;
  mmdLib ??= import("https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs")
    .then(({ default: m }) => {
      m.initialize({
        startOnLoad: false,
        securityLevel: "loose", // strict strips the <br/>/<b> that labels commonly use
        theme: matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "default",
      });
      return m;
    })
    .catch(() => null); // offline: leave the fenced source visible
  const mermaid = await mmdLib;
  if (!mermaid) return;
  for (const [code, src] of pending) {
    try {
      const { svg } = await mermaid.render("mmd" + ++mmdSeq, src);
      mmdCache.set(src, svg);
      if (code.isConnected) swap(code, svg);
    } catch { /* invalid diagram: keep the source */ }
  }
}
document.addEventListener("DOMContentLoaded", drawMermaid);

// a diagram is unreadable at column width — click to fill the window, click/Esc to restore
document.addEventListener("click", (e) => {
  e.target.closest?.(".mermaid")?.classList.toggle("zoom");
});
document.addEventListener("keydown", (e) => {
  if (e.key !== "Escape") return;
  for (const box of document.querySelectorAll(".mermaid.zoom")) box.classList.remove("zoom");
});
<\/script>`;

const docPage = (title: string, body: string) => `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escHtml(title)}</title>
<style>
  :root { --surface: #efeeea; --ink: #1a1a19; --ink-2: #5f5e5a; --line: #e3e1dc;
          --accent: #4a6fa5; --subtle: rgba(127, 127, 127, 0.12); }
  @media (prefers-color-scheme: dark) {
    :root { --surface: #232321; --ink: #ececea; --ink-2: #a3a29c; --line: #383835;
            --accent: #7f9fce; }
  }
  :root { color-scheme: light dark; accent-color: var(--accent); }
  * { box-sizing: border-box; }
  body { margin: 0 auto; max-width: 46rem; padding: 32px 20px;
         background: var(--surface); color: var(--ink);
         font: 16px/1.6 system-ui, sans-serif; }
  h1, h2, h3, h4, h5, h6 { margin: 24px 0 12px; font-weight: 600; line-height: 1.25; }
  h1 { font-size: 1.6em; border-bottom: 1px solid var(--line); padding-bottom: 0.3em; }
  h2 { font-size: 1.3em; border-bottom: 1px solid var(--line); padding-bottom: 0.3em; }
  h3 { font-size: 1.15em; }
  p, ul, ol, pre, table, blockquote { margin: 0 0 14px; }
  ul, ol { padding-left: 1.8em; }
  li { margin: 0.2em 0; }
  li:has(> input[type=checkbox]) { list-style: none; }
  li > input[type=checkbox] { margin: 0 0.45em 0 -1.5em; }
  code { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace;
         font-size: 85%; background: var(--subtle); padding: 0.15em 0.35em;
         border-radius: 2px; }
  pre { background: var(--subtle); padding: 12px 14px; border-radius: 2px;
        overflow-x: auto; line-height: 1.45; }
  pre code { background: transparent; padding: 0; }
  blockquote { padding: 0 1em; color: var(--ink-2);
               border-left: 3px solid var(--line); }
  hr { border: 0; height: 2px; background: var(--line); margin: 24px 0; }
  table { border-collapse: collapse; display: block; max-width: 100%;
          overflow-x: auto; }
  th, td { border: 1px solid var(--line); padding: 5px 11px; }
  th { background: var(--subtle); }
  tr:nth-child(2n) td { background: rgba(127, 127, 127, 0.05); }
  img { max-width: 100%; border-radius: 2px; }
  a { color: var(--accent); text-decoration: none; }
  a:hover { text-decoration: underline; }
  .md-comment { color: var(--ink-2); font-style: italic; font-size: 14px;
                border-left: 2px solid var(--line); padding: 6px 10px;
                margin: 0 0 14px; opacity: 0.85; }
  .file { color: var(--ink-2); font-size: 14px; border-bottom: 1px solid var(--line);
          padding-bottom: 8px; margin-bottom: 16px; }
  .frontmatter { background: var(--subtle); border-left: 3px solid var(--accent);
                 border-radius: 2px; padding: 10px 14px; margin: 0 0 20px;
                 font-size: 14px; }
  .fm-row { display: flex; gap: 8px; margin: 3px 0; }
  .fm-key { color: var(--ink-2); min-width: 90px; }
${mermaidStyles}
</style>
${mermaidScript}
</head>
<body><div class="file">${escHtml(title)}</div>
${body}
</body>
</html>`;

const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>aiwork dashboard</title>
<style>
  :root {
    --surface: #efeeea; --card: #f8f7f4; --ink: #1a1a19; --ink-2: #5f5e5a;
    --line: #e3e1dc; --good: #0ca30c; --warn: #b97f00; --crit: #d03b3b;
    --accent: #4a6fa5;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --surface: #232321; --card: #2c2c2a; --ink: #ececea; --ink-2: #a3a29c;
      --line: #383835; --good: #0ca30c; --warn: #fab219; --crit: #d03b3b;
      --accent: #7f9fce;
    }
  }
  :root { color-scheme: light dark; accent-color: var(--accent); }
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--surface); color: var(--ink);
         font: 16px/1.5 system-ui, sans-serif; }
  header { display: flex; align-items: center; gap: 10px;
           padding: 12px 20px; border-bottom: 1px solid var(--line); }
  header h1 { font-size: 17px; margin: 0; font-weight: 600; }
  #conn { width: 8px; height: 8px; border-radius: 50%; background: var(--crit); }
  #conn.ok { background: var(--good); }
  .toggle { margin-left: auto; color: var(--ink-2); font-size: 14px;
            display: flex; align-items: center; gap: 6px; cursor: pointer; }
  main { padding: 16px 20px; display: grid; gap: 20px; }
  .task { background: var(--card); border: 1px solid var(--line);
          border-radius: 2px; padding: 14px 16px; }
  .task > summary { display: flex; align-items: baseline; gap: 10px;
                    flex-wrap: wrap; cursor: pointer; list-style: none;
                    margin-bottom: 12px; }
  .task > summary::-webkit-details-marker { display: none; }
  .task > summary::before { content: "▸"; color: var(--ink-2); }
  .task[open] > summary::before { content: "▾"; }
  .task:not([open]) > summary { margin-bottom: 0; }
  .task .proj { color: var(--ink-2); font-size: 14px; }
  .task .name { font-weight: 600; }
  .task .m { color: var(--ink-2); font-size: 14px; }
  .task .right { margin-left: auto; }
  .badge { font-size: 13px; padding: 1px 8px; border-radius: 2px;
           border: 1px solid var(--line); color: var(--ink-2); }
  .badge.running { color: var(--good); border-color: var(--good); }
  .badge.in-progress { color: var(--warn); border-color: var(--warn); }
  .badge.blocked { color: var(--crit); border-color: var(--crit); }
  .badge.done { color: var(--good); border-color: var(--good); }
  .badge.abandoned { text-decoration: line-through; }
  .badge.not-started { color: var(--accent); border-color: var(--accent); }
  .badge.unknown { border-style: dashed; }
  .badge.running::before { content: "● "; animation: pulse 1.5s infinite; }
  @keyframes pulse { 50% { opacity: 0.3; } }
  .body { display: grid; grid-template-columns: 3fr 2fr; gap: 16px; }
  @media (max-width: 900px) { .body { grid-template-columns: 1fr; } }
  .board { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px;
           align-content: start; }
  .col :is(h3, summary) { font-size: 13px; text-transform: uppercase;
            letter-spacing: 0.05em; color: var(--ink-2); margin: 0 0 8px;
            font-weight: 600; }
  .col summary { cursor: pointer; }
  .col details:not([open]) summary { margin-bottom: 0; }
  .card { border: 1px solid var(--line); border-left-width: 3px; border-radius: 2px;
          padding: 8px 10px; margin-bottom: 8px; background: var(--card); }
  .card .t { font-weight: 500; margin-bottom: 2px; }
  .card .m { font-size: 14px; color: var(--ink-2); }
  .card.done { border-left-color: var(--good); }
  .card.in-progress { border-left-color: var(--warn); }
  .card.blocked { border-left-color: var(--crit); }
  .card.ready { border-left-color: var(--accent); }
  .notes { border: 1px solid var(--line); border-radius: 2px; padding: 10px 14px;
           overflow: auto; max-height: 420px; font-size: 15px; }
  .notes .nt { font-size: 13px; text-transform: uppercase; letter-spacing: 0.05em;
               color: var(--ink-2); margin: 0 0 8px; font-weight: 600;
               position: sticky; top: -10px; background: var(--card); padding: 4px 0; }
  .notes pre { background: var(--surface); padding: 6px 8px; border-radius: 2px;
               overflow-x: auto; font-size: 13px; line-height: 1.45; }
  .notes code { background: var(--surface); padding: 0 3px; border-radius: 2px;
                font-size: 90%; }
  .notes pre code { background: transparent; padding: 0; font-size: 100%; }
  .notes ul, .notes ol { padding-left: 20px; margin: 4px 0; }
  .notes p { margin: 6px 0; }
  .notes :is(h1, h2, h3, h4, h5, h6):not(.nt) { margin: 12px 0 4px; font-size: 15px;
              font-weight: 600; border: 0; padding: 0; }
  .notes li:has(> input[type=checkbox]) { list-style: none; }
  .notes li > input[type=checkbox] { margin: 0 0.4em 0 -1.3em; }
  .notes blockquote { margin: 6px 0; padding: 0 10px; color: var(--ink-2);
                      border-left: 3px solid var(--line); }
  .notes table { border-collapse: collapse; margin: 6px 0; display: block;
                 max-width: 100%; overflow-x: auto; font-size: 14px; }
  .notes th, .notes td { border: 1px solid var(--line); padding: 3px 8px; }
  .notes hr { border: 0; height: 1px; background: var(--line); margin: 12px 0; }
${mermaidStyles}
  .notes .md-comment { color: var(--ink-2); font-style: italic; font-size: 13px;
                       border-left: 2px solid var(--line); padding: 2px 8px;
                       margin: 6px 0; opacity: 0.85; }
  .empty { color: var(--ink-2); font-style: italic; }
  .state-group { margin-bottom: 6px; }
  .state-group > summary { cursor: pointer; color: var(--ink-2); font-size: 14px;
                  text-transform: uppercase; letter-spacing: 0.05em;
                  margin-bottom: 6px; }
  .state-group > .task { margin-bottom: 10px; }
  .idle-task > summary { display: flex; gap: 8px; align-items: baseline;
              cursor: pointer; list-style: none;
              padding: 5px 8px; border-bottom: 1px solid var(--line); }
  .idle-task > summary::-webkit-details-marker { display: none; }
  .idle-task > summary::before { content: "▸"; color: var(--ink-2); }
  .idle-task[open] > summary::before { content: "▾"; }
  .idle-task > summary:hover { background: var(--surface); }
  .idle-task .proj { color: var(--ink-2); font-size: 14px; }
  .idle-task .m { color: var(--ink-2); font-size: 14px; }
  .idle-task .right { margin-left: auto; }
  .idle-body { padding: 10px 8px 14px; border-bottom: 1px solid var(--line); }
  a { color: inherit; text-decoration: none; }
  a:hover { text-decoration: underline; }
  a.doc { color: var(--accent); font-size: 14px; }
</style>
</head>
<body>
<header><div id="conn"></div><h1>aiwork dashboard</h1>
  <span id="meta" class="badge"></span>
  <label class="toggle"><input type="checkbox" id="chrono"> newest first</label>
</header>
<main id="main"><p class="empty">Loading…</p></main>
${mermaidScript}
<script>
const esc = (s) => s.replace(/[&<>"]/g, (c) =>
  ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

const COLS = [
  ["blocked", "Blocked"], ["ready", "Ready"],
  ["in-progress", "In progress"], ["done", "Done"],
];

const STATE_LABEL = {
  unknown: "no status", "not-started": "not started",
  "in-progress": "in progress", blocked: "blocked",
  done: "done", abandoned: "abandoned",
};

// The board's only grouping. Live work first; settled states collapse.
const STATE_GROUPS = [
  ["in-progress", "In progress", true],
  ["blocked", "Blocked", true],
  ["not-started", "Not started", true],
  ["unknown", "No status — add one to spec.md or plan.md", true],
  ["done", "Done", false],
  ["abandoned", "Abandoned", false],
];

// Flat, newest-first listing instead of the state sections. Survives reloads;
// a browser that refuses storage just starts grouped every time.
let chrono = false;
try {
  chrono = localStorage.getItem("aiboard-chrono") === "1";
} catch { /* storage blocked */ }

// open/closed choices for every disclosure, so the SSE re-render can restore them
const discState = new Map();
document.addEventListener("toggle", (e) => {
  const key = e.target.dataset?.disc;
  if (key !== undefined) discState.set(key, e.target.open);
}, true);
// a link inside a summary should just follow the link, not toggle the disclosure
document.addEventListener("click", (e) => {
  if (e.target.closest?.("summary a")) e.stopPropagation();
}, true);

const disc = (key, dflt, cls, summary, body) =>
  \`<details class="\${cls}" data-disc="\${esc(key)}"\${
    (discState.get(key) ?? dflt) ? " open" : ""}>
    <summary>\${summary}</summary>\${body}</details>\`;

const href = (task, ...segs) =>
  \`/f/\${task.pi}/\${[task.name, ...segs].map(encodeURIComponent).join("/")}\`;

function card(t, task) {
  const crit = t.criteriaTotal
    ? \` · \${t.criteriaDone}/\${t.criteriaTotal} criteria\` : "";
  const blk = t.blocked ? \` · waits on \${t.blockedBy.join(", ")}\` : "";
  const cls = t.blocked ? "blocked" : t.status;
  return \`<div class="card \${cls}">
    <div class="t"><a href="\${href(task, "tickets", t.file)}" target="_blank">\${esc(t.title)}</a></div>
    <div class="m">\${t.num || t.file}\${crit}\${blk}</div></div>\`;
}

const docLinks = (task) => task.docs.map((d) =>
  \`<a class="doc" href="\${href(task, d)}" target="_blank">\${esc(d)}</a>\`).join("");

function age(mtime) {
  const s = (Date.now() - mtime) / 1000;
  if (s < 3600) return Math.round(s / 60) + "m";
  if (s < 86400) return Math.round(s / 3600) + "h";
  if (s < 30 * 86400) return Math.round(s / 86400) + "d";
  return Math.round(s / (30 * 86400)) + "mo";
}

// The section header already names the state, so a badge only earns its place
// when it adds something: the reason for a block, or a frontmatter word that
// disagrees with the state the tickets prove (a stale "active" on done work).
function stateBadge(t, withLabel) {
  const parts = withLabel ? [STATE_LABEL[t.state]] : [];
  if (t.state === "blocked" && t.blockedReason) parts.push(t.blockedReason);
  if (t.planned && t.docStatus &&
      STATE_LABEL[t.state] !== t.docStatus.toLowerCase()) {
    parts.push(\`spec says "\${t.docStatus}"\`);
  }
  if (!parts.length) return "";
  return \`<span class="badge \${t.state}">\${esc(parts.join(" · "))}</span>\`;
}

// Unfinished work gets the full board plus its notes log — collapsible like any
// other row, running included, so a long board can be folded out of the way.
function taskCard(task) {
  const notes = task.notes
    ? \`<div class="notes"><h3 class="nt"><a href="\${href(task, task.notesFile)}" target="_blank">\${esc(task.notesFile)}</a></h3>\${task.notes}</div>\`
    : '<div class="notes"><h3 class="nt">notes</h3><p class="empty">No notes yet.</p></div>';
  const done = task.tickets.filter((t) => t.status === "done").length;
  const head = \`<span class="proj">\${esc(task.proj)} /</span>
    <span class="name">\${esc(task.name)}</span>
    \${task.running ? '<span class="badge running">running</span>' : ""}
    \${task.tickets.length
      ? \`<span class="m">\${done}/\${task.tickets.length} tickets</span>\` : ""}
    \${stateBadge(task, chrono)}
    \${task.hasReview ? '<span class="badge">✓ reviewed</span>' : ""}
    \${docLinks(task)}
    <span class="m right">\${age(task.mtime)} ago</span>\`;
  return disc("task/" + taskKey(task), true, "task", head,
    \`<div class="body">\${boardHtml(task, false)}\${notes}</div>\`);
}

function idleRow(t) {
  const done = t.tickets.filter((x) => x.status === "done").length;
  const sum = t.planned
    ? \`<span class="m">\${done}/\${t.tickets.length} tickets</span>\`
    : \`<span class="m">no tickets\${
        t.docCriteriaTotal
          ? \` · \${t.docCriteriaDone}/\${t.docCriteriaTotal} spec criteria\`
          : ""}</span>\`;
  const head = \`<span class="proj">\${esc(t.proj)} /</span>
    <span>\${esc(t.name)}</span>\${sum}\${stateBadge(t, chrono)}\${docLinks(t)}
    \${t.hasReview ? '<span class="badge">✓ reviewed</span>' : ""}
    <span class="m right">\${age(t.mtime)} ago</span>\`;
  // finished tasks keep their tickets — expand the row to read them
  return disc("idle/" + taskKey(t), false, "idle-task", head,
    \`<div class="idle-body">\${boardHtml(t, true)}</div>\`);
}

const taskKey = (task) => task.pi + "/" + task.name;

function boardHtml(task, doneOpenByDefault) {
  if (!task.tickets.length) {
    return '<div class="empty">Not planned yet — no tickets.</div>';
  }
  const cols = COLS.map(([key, label]) => {
    const items = task.tickets.filter((t) =>
      key === "blocked" ? t.blocked : t.status === key && !t.blocked);
    const body = items.map((t) => card(t, task)).join("") ||
      '<div class="empty">—</div>';
    const head = \`\${label} (\${items.length})\`;
    // done piles up — keep it behind a disclosure of its own
    const inner = key === "done" && items.length
      ? disc(taskKey(task) + "/done", doneOpenByDefault, "", head, body)
      : \`<h3>\${head}</h3>\${body}\`;
    return \`<div class="col">\${inner}</div>\`;
  }).join("");
  return \`<div class="board">\${cols}</div>\`;
}

function render(projects) {
  const tasks = projects.flatMap((p, pi) =>
    p.tasks.map((t) => ({ ...t, proj: p.name, pi })));
  tasks.sort((a, b) => b.running - a.running || b.mtime - a.mtime);
  const counts = STATE_GROUPS
    .map(([state, label]) =>
      \`\${tasks.filter((t) => t.state === state).length} \${label.toLowerCase()}\`)
    .join(" · ");
  document.getElementById("meta").textContent = counts;
  if (!tasks.length) {
    document.getElementById("main").innerHTML =
      '<p class="empty">No task folders found.</p>';
    return;
  }
  const row = (t) => t.expanded ? taskCard(t) : idleRow(t);
  document.getElementById("main").innerHTML = chrono
    // Folder names start with the date they were opened, so the name sorts as
    // the date does — newest task first, state ignored.
    ? [...tasks].sort((a, b) => b.name.localeCompare(a.name)).map(row).join("")
    // Otherwise one section per lifecycle state.
    : STATE_GROUPS.map(([state, label, open]) => {
      const rows = tasks.filter((t) => t.state === state);
      if (!rows.length) return "";
      return disc("state/" + state, open, "state-group",
        \`\${label} (\${rows.length})\`, rows.map(row).join(""));
    }).join("");
  drawMermaid();
  // keep note logs scrolled to the latest entries
  for (const n of document.querySelectorAll(".notes")) n.scrollTop = n.scrollHeight;
}

let lastData = [];
const draw = (data) => render(lastData = data);

const chronoBox = document.getElementById("chrono");
chronoBox.checked = chrono;
chronoBox.addEventListener("change", () => {
  chrono = chronoBox.checked;
  try {
    localStorage.setItem("aiboard-chrono", chrono ? "1" : "0");
  } catch { /* storage blocked */ }
  render(lastData);
});

const conn = document.getElementById("conn");
function connect() {
  const es = new EventSource("/events");
  es.onopen = () => conn.classList.add("ok");
  es.onmessage = (e) => draw(JSON.parse(e.data));
  es.onerror = () => {
    conn.classList.remove("ok");
    es.close();
    setTimeout(connect, 2000);
  };
}
fetch("/state").then((r) => r.json()).then(draw);
connect();
</script>
</body>
</html>`;

Deno.serve({
  port,
  onListen: async ({ port }) => {
    const url = `http://localhost:${port}`;
    $.logStep(`aiwork dashboard on ${url}`);
    $.logLight(`watching: ${projects.map((p) => p.aiwork).join(", ")}`);
    if (open) await $`xdg-open ${url}`.noThrow().quiet();
  },
}, async (req) => {
  const path = new URL(req.url).pathname;
  if (path === "/state") {
    return Response.json(await scan());
  }
  // /f/<projectIndex>/<path inside .aiwork> — serve task artifacts
  const f = path.match(/^\/f\/(\d+)\/(.+)$/);
  if (f) {
    const proj = projects[Number(f[1])];
    if (!proj) return new Response("unknown project", { status: 404 });
    const rel = f[2].split("/").map(decodeURIComponent).join("/");
    const target = proj.aiwork.join(rel).resolve();
    if (!target.toString().startsWith(proj.aiwork.resolve().toString() + "/")) {
      return new Response("forbidden", { status: 403 });
    }
    if (!target.isFileSync()) return new Response("not found", { status: 404 });
    const text = await target.readText();
    if (target.toString().endsWith(".md")) {
      const fm = text.match(/^---\n([\s\S]*?)\n---\n?/);
      const body = (fm ? fmToHtml(fm[1]) : "") +
        mdToHtml(fm ? text.slice(fm[0].length) : text);
      return new Response(docPage(target.basename(), body), {
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    }
    const type = target.toString().endsWith(".html") ? "text/html" : "text/plain";
    return new Response(text, {
      headers: { "content-type": `${type}; charset=utf-8` },
    });
  }
  if (path === "/events") {
    let ctrl: ReadableStreamDefaultController<Uint8Array>;
    const stream = new ReadableStream<Uint8Array>({
      start(controller) {
        ctrl = controller;
        clients.add(controller);
        controller.enqueue(enc.encode(": connected\n\n"));
      },
      cancel() {
        clients.delete(ctrl);
      },
    });
    return new Response(stream, {
      headers: { "content-type": "text/event-stream", "cache-control": "no-cache" },
    });
  }
  return new Response(html, { headers: { "content-type": "text/html" } });
});
