#!/usr/bin/env -S deno run --allow-run --allow-env --allow-read --allow-net
// Live dashboard for .aiwork implementation sessions: kanban board of tickets
// plus the implementation-notes log, self-updating via file watcher + SSE.
//
// Usage: aiboard [project-dir ...] [--port 4517] [--no-open]
// Default project dir is the cwd. Each dir must contain an .aiwork/ folder.
import $ from "jsr:@david/dax";

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
  running: boolean;
  active: boolean; // running, or has unfinished tickets — gets a full board section
}

interface Project {
  root: string;
  name: string;
  tasks: TaskFolder[];
}

const escHtml = (s: string) =>
  s.replace(/[&<>"]/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c] as string));

// minimal markdown: headings, bullets, bold, inline code, fenced code
function mdToHtml(src: string): string {
  const out: string[] = [];
  let inCode = false, inList = false;
  for (const line of src.split("\n")) {
    if (line.startsWith("```")) {
      out.push(inCode ? "</pre>" : "<pre>");
      inCode = !inCode;
      continue;
    }
    if (inCode) {
      out.push(escHtml(line));
      continue;
    }
    const h = escHtml(line)
      .replace(/`([^`]+)`/g, "<code>$1</code>")
      .replace(/\*\*([^*]+)\*\*/g, "<b>$1</b>");
    const isLi = /^\s*[-*] /.test(line);
    if (isLi && !inList) {
      out.push("<ul>");
      inList = true;
    }
    if (!isLi && inList) {
      out.push("</ul>");
      inList = false;
    }
    if (/^#{1,6} /.test(line)) out.push("<h4>" + h.replace(/^#+ /, "") + "</h4>");
    else if (isLi) out.push("<li>" + h.replace(/^\s*[-*] /, "") + "</li>");
    else if (line.trim()) out.push("<p>" + h + "</p>");
  }
  if (inList) out.push("</ul>");
  if (inCode) out.push("</pre>");
  return out.join("\n");
}

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

  const running = tickets.some((t) => t.status === "in-progress") ||
    Date.now() - mtime < 15 * 60 * 1000;
  const active = running || tickets.some((t) => t.status !== "done");
  if (!active) notes = null; // idle rows don't ship their notes
  else if (notes) notes = mdToHtml(notes.split("\n").slice(-150).join("\n"));

  return { name: dir.basename(), docs, tickets, notes, notesFile, hasReview, mtime, running, active };
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

const docPage = (title: string, body: string) => `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escHtml(title)}</title>
<style>
  :root { --surface: #efeeea; --ink: #1a1a19; --ink-2: #5f5e5a; --line: #e3e1dc; }
  @media (prefers-color-scheme: dark) {
    :root { --surface: #232321; --ink: #ececea; --ink-2: #a3a29c; --line: #383835; }
  }
  body { margin: 0 auto; max-width: 46rem; padding: 32px 20px;
         background: var(--surface); color: var(--ink);
         font: 16px/1.6 system-ui, sans-serif; }
  h4 { font-size: 18px; margin: 20px 0 6px; }
  pre { background: rgba(127, 127, 127, 0.12); padding: 10px 12px;
        border-radius: 6px; overflow-x: auto; }
  code { background: rgba(127, 127, 127, 0.12); padding: 0 4px; border-radius: 3px; }
  .file { color: var(--ink-2); font-size: 14px; border-bottom: 1px solid var(--line);
          padding-bottom: 8px; margin-bottom: 16px; }
  .fm { color: var(--ink-2); font-size: 13px; }
</style>
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
  * { box-sizing: border-box; }
  body { margin: 0; background: var(--surface); color: var(--ink);
         font: 16px/1.5 system-ui, sans-serif; }
  header { display: flex; align-items: center; gap: 10px;
           padding: 12px 20px; border-bottom: 1px solid var(--line); }
  header h1 { font-size: 17px; margin: 0; font-weight: 600; }
  #conn { width: 8px; height: 8px; border-radius: 50%; background: var(--crit); }
  #conn.ok { background: var(--good); }
  main { padding: 16px 20px; display: grid; gap: 20px; }
  .task { background: var(--card); border: 1px solid var(--line);
          border-radius: 8px; padding: 14px 16px; }
  .task-head { display: flex; align-items: baseline; gap: 10px; flex-wrap: wrap;
               margin-bottom: 10px; }
  .task-head .proj { color: var(--ink-2); font-size: 14px; }
  .task-head .name { font-weight: 600; }
  .badge { font-size: 13px; padding: 1px 8px; border-radius: 10px;
           border: 1px solid var(--line); color: var(--ink-2); }
  .badge.running { color: var(--good); border-color: var(--good); }
  .badge.running::before { content: "● "; animation: pulse 1.5s infinite; }
  @keyframes pulse { 50% { opacity: 0.3; } }
  .body { display: grid; grid-template-columns: 3fr 2fr; gap: 16px; }
  @media (max-width: 900px) { .body { grid-template-columns: 1fr; } }
  .board { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px;
           align-content: start; }
  .col h3 { font-size: 13px; text-transform: uppercase; letter-spacing: 0.05em;
            color: var(--ink-2); margin: 0 0 8px; font-weight: 600; }
  .card { border: 1px solid var(--line); border-left-width: 3px; border-radius: 6px;
          padding: 8px 10px; margin-bottom: 8px; background: var(--card); }
  .card .t { font-weight: 500; margin-bottom: 2px; }
  .card .m { font-size: 14px; color: var(--ink-2); }
  .card.done { border-left-color: var(--good); }
  .card.in-progress { border-left-color: var(--warn); }
  .card.blocked { border-left-color: var(--crit); }
  .card.ready { border-left-color: var(--accent); }
  .notes { border: 1px solid var(--line); border-radius: 6px; padding: 10px 14px;
           overflow: auto; max-height: 420px; font-size: 15px; }
  .notes h3 { font-size: 13px; text-transform: uppercase; letter-spacing: 0.05em;
              color: var(--ink-2); margin: 0 0 8px; font-weight: 600;
              position: sticky; top: -10px; background: var(--card); padding: 4px 0; }
  .notes pre { background: var(--surface); padding: 6px 8px; border-radius: 4px;
               overflow-x: auto; }
  .notes code { background: var(--surface); padding: 0 3px; border-radius: 3px; }
  .notes ul { padding-left: 20px; margin: 4px 0; }
  .notes h4 { margin: 10px 0 4px; font-size: 15px; }
  .empty { color: var(--ink-2); font-style: italic; }
  .idle summary { cursor: pointer; color: var(--ink-2); font-size: 14px;
                  text-transform: uppercase; letter-spacing: 0.05em;
                  margin-bottom: 6px; }
  .idle-row { display: flex; gap: 8px; align-items: baseline;
              padding: 5px 8px; border-bottom: 1px solid var(--line); }
  .idle-row .proj { color: var(--ink-2); font-size: 14px; }
  .idle-row .m { color: var(--ink-2); font-size: 14px; }
  .idle-row .right { margin-left: auto; }
  a { color: inherit; text-decoration: none; }
  a:hover { text-decoration: underline; }
  a.doc { color: var(--accent); font-size: 14px; }
</style>
</head>
<body>
<header><div id="conn"></div><h1>aiwork dashboard</h1>
  <span id="meta" class="badge"></span></header>
<main id="main"><p class="empty">Loading…</p></main>
<script>
const esc = (s) => s.replace(/[&<>"]/g, (c) =>
  ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

const COLS = [
  ["blocked", "Blocked"], ["ready", "Ready"],
  ["in-progress", "In progress"], ["done", "Done"],
];

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

function idleRow(t) {
  const sum = t.tickets.length ? \`<span class="m">\${t.tickets.length} tickets done</span>\` : "";
  return \`<div class="idle-row"><span class="proj">\${esc(t.proj)} /</span>
    <span>\${esc(t.name)}</span>\${sum}\${docLinks(t)}
    \${t.hasReview ? '<span class="badge">✓ reviewed</span>' : ""}
    <span class="m right">\${age(t.mtime)} ago</span></div>\`;
}

function render(projects) {
  const tasks = projects.flatMap((p, pi) =>
    p.tasks.map((t) => ({ ...t, proj: p.name, pi })));
  tasks.sort((a, b) => b.running - a.running || b.mtime - a.mtime);
  const active = tasks.filter((t) => t.active);
  const idle = tasks.filter((t) => !t.active);
  document.getElementById("meta").textContent =
    \`\${tasks.filter((t) => t.running).length} running / \${tasks.length} tasks\`;
  if (!tasks.length) {
    document.getElementById("main").innerHTML =
      '<p class="empty">No task folders found.</p>';
    return;
  }
  const idleHtml = idle.length
    ? \`<details class="idle"\${active.length ? "" : " open"}>
        <summary>Idle / done (\${idle.length})</summary>
        \${idle.map(idleRow).join("")}</details>\`
    : "";
  document.getElementById("main").innerHTML = (active.length
    ? ""
    : '<p class="empty">Nothing running.</p>') + active.map((task) => {
    const cols = COLS.map(([key, label]) => {
      const items = task.tickets.filter((t) =>
        key === "blocked" ? t.blocked : t.status === key && !t.blocked);
      return \`<div class="col"><h3>\${label} (\${items.length})</h3>
        \${items.map((t) => card(t, task)).join("") || '<div class="empty">—</div>'}</div>\`;
    }).join("");
    const board = task.tickets.length
      ? \`<div class="board">\${cols}</div>\`
      : '<div class="empty">No tickets — spec-level work item.</div>';
    const notes = task.notes
      ? \`<div class="notes"><h3><a href="\${href(task, task.notesFile)}" target="_blank">\${esc(task.notesFile)}</a></h3>\${task.notes}</div>\`
      : '<div class="notes"><h3>notes</h3><p class="empty">No notes yet.</p></div>';
    return \`<section class="task">
      <div class="task-head">
        <span class="proj">\${esc(task.proj)} /</span>
        <span class="name">\${esc(task.name)}</span>
        \${task.running ? '<span class="badge running">running</span>' : ""}
        \${task.hasReview ? '<span class="badge">✓ reviewed</span>' : ""}
        \${docLinks(task)}
      </div>
      <div class="body">\${board}\${notes}</div>
    </section>\`;
  }).join("") + idleHtml;
  // keep note logs scrolled to the latest entries
  for (const n of document.querySelectorAll(".notes")) n.scrollTop = n.scrollHeight;
}

const conn = document.getElementById("conn");
function connect() {
  const es = new EventSource("/events");
  es.onopen = () => conn.classList.add("ok");
  es.onmessage = (e) => render(JSON.parse(e.data));
  es.onerror = () => {
    conn.classList.remove("ok");
    es.close();
    setTimeout(connect, 2000);
  };
}
fetch("/state").then((r) => r.json()).then(render);
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
      const body = (fm ? `<pre class="fm">${escHtml(fm[1])}</pre>` : "") +
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
