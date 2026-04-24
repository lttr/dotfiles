#!/usr/bin/env node
/**
 * Scan a directory tree for Claude Code skill artifacts and emit an
 * interactive HTML graph.
 *
 * Requires: Node 23.6+ (native TypeScript stripping, no flags needed).
 * Dependencies: Node stdlib only.
 */

import { readFile, readdir, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { dirname, extname, join, relative, resolve, basename, sep } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { spawn } from "node:child_process";
import { argv, exit, platform, stderr, stdout } from "node:process";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type NodeType =
  | "root" | "skill" | "command" | "agent" | "plugin" | "marketplace"
  | "mcp" | "bin" | "file" | "hook";

type EdgeType =
  | "references" | "invokes" | "companion-of" | "depends-on"
  | "reads" | "owns" | "triggers" | "registers" | "semantic";

interface GNode {
  id: string;
  label: string;
  type: NodeType;
  desc?: string;
  path?: string;
  tools?: string;
}

interface GEdge {
  source: string;
  target: string;
  label: string;
  type: EdgeType;
}

interface Frontmatter {
  [k: string]: string;
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const SKIP_DIRS = new Set([
  ".git", "node_modules", "dist", "build", ".venv", "venv",
  "__pycache__", ".next", ".nuxt", "target", ".cache",
]);

const FRONTMATTER_RE = /^---\s*\n([\s\S]*?)\n---\s*\n?([\s\S]*)$/;
const AT_REF_RE = /@([\w./-]+\.[a-zA-Z0-9]+)/g;
const SLASH_CMD_RE = /(?<![\w/`])\/([a-zA-Z][\w-]*(?::[\w-]+)?)\b/g;
const MCP_TOOL_RE = /\bmcp__([\w-]+)__([\w-]+)\b/g;
const BASH_ALLOW_RE = /Bash\(\s*([^)\s:]+)(?::[^)]*)?\s*\)/g;
const COMPANION_RE = /[Cc]ompanion\s+(?:to|of)\s+\/?([\w:-]+)/g;
const FILE_PATH_RE = /\b((?:[a-zA-Z0-9_\-./]+\/)?[a-zA-Z0-9_-]+\.(?:md|ts|js|py|sh|json))\b/g;

// ---------------------------------------------------------------------------
// Frontmatter + walk helpers
// ---------------------------------------------------------------------------

function parseFrontmatter(text: string): { fm: Frontmatter; body: string } {
  const m = FRONTMATTER_RE.exec(text);
  if (!m) return { fm: {}, body: text };
  const fm: Frontmatter = {};
  for (const line of m[1].split(/\r?\n/)) {
    if (!line.trim() || line.trimStart().startsWith("#")) continue;
    const match = /^([A-Za-z][\w-]*)\s*:\s*(.*)$/.exec(line);
    if (match) fm[match[1]] = match[2].trim();
  }
  return { fm, body: m[2] };
}

async function* walk(root: string): AsyncGenerator<string> {
  let entries;
  try {
    entries = await readdir(root, { withFileTypes: true });
  } catch {
    return;
  }
  for (const e of entries) {
    if (SKIP_DIRS.has(e.name)) continue;
    const full = join(root, e.name);
    if (e.isDirectory()) {
      yield* walk(full);
    } else if (e.isFile()) {
      yield full;
    }
  }
}

async function readSafe(p: string): Promise<string> {
  try { return await readFile(p, "utf8"); } catch { return ""; }
}

// ---------------------------------------------------------------------------
// Graph builder
// ---------------------------------------------------------------------------

class Graph {
  nodes = new Map<string, GNode>();
  edges: GEdge[] = [];
  private edgeKeys = new Set<string>();

  addNode(n: GNode): void {
    const existing = this.nodes.get(n.id);
    if (existing) {
      for (const [k, v] of Object.entries(n)) {
        if (v && !(existing as any)[k]) (existing as any)[k] = v;
      }
      return;
    }
    this.nodes.set(n.id, n);
  }

  addEdge(e: GEdge): void {
    const key = `${e.source}->${e.target}#${e.type}`;
    if (this.edgeKeys.has(key)) return;
    this.edgeKeys.add(key);
    this.edges.push(e);
  }
}

const nid = (kind: NodeType, name: string) => `${kind}:${name}`;

interface SkillEntry { path: string; fm: Frontmatter; body: string; }
interface CommandEntry extends SkillEntry { namespace: string; }

async function discover(roots: string[]): Promise<Graph> {
  const g = new Graph();
  const skills: SkillEntry[] = [];
  const commands: CommandEntry[] = [];
  const agents: SkillEntry[] = [];
  const plugins: string[] = [];
  const marketplaces: string[] = [];
  const mcps: string[] = [];
  const settings: string[] = [];
  const seen = new Set<string>();

  for (const root of roots) {
    if (!existsSync(root)) continue;
    for await (const p of walk(root)) {
      if (seen.has(p)) continue;
      seen.add(p);
      const name = basename(p);
      if (name === "SKILL.md") {
        const text = await readSafe(p);
        const { fm, body } = parseFrontmatter(text);
        skills.push({ path: p, fm, body });
      } else if (name === "plugin.json") {
        plugins.push(p);
      } else if (name === "marketplace.json") {
        marketplaces.push(p);
      } else if (name === ".mcp.json" || name === "mcp.json") {
        mcps.push(p);
      } else if (name === "settings.json" || name === "settings.local.json") {
        settings.push(p);
      } else if (extname(p) === ".md") {
        const parent = basename(dirname(p));
        const grand = basename(dirname(dirname(p)));
        if (parent === "commands" || grand === "commands") {
          const text = await readSafe(p);
          const { fm, body } = parseFrontmatter(text);
          const namespace = (grand === "commands" && parent !== "commands") ? parent + ":" : "";
          commands.push({ path: p, fm, body, namespace });
        } else if (parent === "agents") {
          const text = await readSafe(p);
          const { fm, body } = parseFrontmatter(text);
          agents.push({ path: p, fm, body });
        }
      }
    }
  }

  // --- Register nodes ---
  for (const s of skills) {
    const name = s.fm.name || basename(dirname(s.path));
    g.addNode({
      id: nid("skill", name), label: name, type: "skill",
      desc: s.fm.description, path: s.path, tools: s.fm["allowed-tools"],
    });
  }
  for (const c of commands) {
    const name = c.namespace + (c.fm.name || basename(c.path, extname(c.path)));
    g.addNode({
      id: nid("command", name), label: name, type: "command",
      desc: c.fm.description, path: c.path, tools: c.fm["allowed-tools"],
    });
  }
  for (const a of agents) {
    const name = a.fm.name || basename(a.path, extname(a.path));
    g.addNode({
      id: nid("agent", name), label: name, type: "agent",
      desc: a.fm.description, path: a.path,
    });
  }

  // --- Plugins + marketplaces ---
  const pluginDirToNid = new Map<string, string>();
  for (const p of plugins) {
    let data: any = {};
    try { data = JSON.parse(await readSafe(p)); } catch { continue; }
    const pname = data.name || basename(dirname(p));
    const id = nid("plugin", pname);
    g.addNode({ id, label: pname, type: "plugin", desc: data.description, path: p });
    pluginDirToNid.set(dirname(p), id);
  }
  for (const p of marketplaces) {
    let data: any = {};
    try { data = JSON.parse(await readSafe(p)); } catch { continue; }
    const mname = data.name || basename(dirname(p));
    const id = nid("marketplace", mname);
    g.addNode({ id, label: mname, type: "marketplace", desc: data.description, path: p });
    for (const plug of data.plugins || []) {
      if (plug?.name) {
        const pid = nid("plugin", plug.name);
        g.addNode({ id: pid, label: plug.name, type: "plugin", desc: plug.description });
        g.addEdge({ source: id, target: pid, label: "lists", type: "owns" });
      }
    }
  }

  // --- MCP server configs ---
  for (const p of mcps) {
    let data: any = {};
    try { data = JSON.parse(await readSafe(p)); } catch { continue; }
    const servers = data.mcpServers || data.servers || {};
    if (servers && typeof servers === "object") {
      for (const sname of Object.keys(servers)) {
        g.addNode({ id: nid("mcp", sname), label: sname, type: "mcp", path: p });
      }
    }
  }

  // --- Plugin ownership ---
  const assignOwner = (childPath: string, childId: string) => {
    for (const [dir, pid] of pluginDirToNid) {
      if (childPath.startsWith(dir + sep)) {
        g.addEdge({ source: pid, target: childId, label: "contains", type: "owns" });
      }
    }
  };
  for (const s of skills) {
    const name = s.fm.name || basename(dirname(s.path));
    assignOwner(s.path, nid("skill", name));
  }
  for (const c of commands) {
    const name = c.namespace + (c.fm.name || basename(c.path, extname(c.path)));
    assignOwner(c.path, nid("command", name));
  }
  for (const a of agents) {
    const name = a.fm.name || basename(a.path, extname(a.path));
    assignOwner(a.path, nid("agent", name));
  }

  // --- Body parsing for edges ---
  const knownSkills = new Set(
    [...g.nodes.keys()].filter((k) => k.startsWith("skill:")).map((k) => k.slice(6))
  );
  const knownCommands = new Set(
    [...g.nodes.keys()].filter((k) => k.startsWith("command:")).map((k) => k.slice(8))
  );

  const resolveSlashTarget = (name: string): string | null => {
    if (knownSkills.has(name)) return nid("skill", name);
    if (knownCommands.has(name)) return nid("command", name);
    const short = name.includes(":") ? name.split(":").pop()! : name;
    if (knownSkills.has(short)) return nid("skill", short);
    if (knownCommands.has(short)) return nid("command", short);
    return null;
  };

  const PATH_PREFIXES = new Set(["usr", "etc", "var", "home", "tmp", "bin", "opt"]);

  const processBody = (srcNid: string, fm: Frontmatter, body: string) => {
    // @file refs
    for (const m of body.matchAll(AT_REF_RE)) {
      const ref = m[1];
      const stem = basename(ref, extname(ref));
      if (knownSkills.has(stem)) {
        g.addEdge({ source: srcNid, target: nid("skill", stem), label: `@${ref}`, type: "references" });
      } else {
        const fid = nid("file", ref);
        g.addNode({ id: fid, label: ref, type: "file" });
        g.addEdge({ source: srcNid, target: fid, label: `@${ref}`, type: "references" });
      }
    }

    // /slash-command invocations
    for (const m of body.matchAll(SLASH_CMD_RE)) {
      const name = m[1];
      if (PATH_PREFIXES.has(name.toLowerCase())) continue;
      const tgt = resolveSlashTarget(name);
      if (tgt && tgt !== srcNid) {
        g.addEdge({ source: srcNid, target: tgt, label: `/${name}`, type: "invokes" });
      }
    }

    // Companion phrases
    const textAll = (fm.description || "") + "\n" + body;
    for (const m of textAll.matchAll(COMPANION_RE)) {
      const name = m[1].replace(/^\//, "");
      const tgt = resolveSlashTarget(name);
      if (tgt && tgt !== srcNid) {
        g.addEdge({ source: srcNid, target: tgt, label: "companion-of", type: "companion-of" });
      }
    }

    // MCP tool mentions
    for (const m of body.matchAll(MCP_TOOL_RE)) {
      const server = m[1];
      const mid = nid("mcp", server);
      g.addNode({ id: mid, label: server, type: "mcp" });
      g.addEdge({
        source: srcNid, target: mid,
        label: `mcp__${server}__${m[2]}`, type: "depends-on",
      });
    }

    // allowed-tools → bash binaries
    const tools = fm["allowed-tools"] || "";
    for (const m of tools.matchAll(BASH_ALLOW_RE)) {
      const cmd = m[1].trim();
      if (!cmd) continue;
      const bid = nid("bin", cmd);
      g.addNode({ id: bid, label: cmd, type: "bin" });
      g.addEdge({ source: srcNid, target: bid, label: `Bash(${cmd})`, type: "depends-on" });
    }

    // Script file mentions (loose)
    for (const m of body.matchAll(FILE_PATH_RE)) {
      const ref = m[1];
      if (body.includes("@" + ref)) continue;
      const stem = basename(ref, extname(ref));
      if (knownSkills.has(stem) || stem === "SKILL") continue;
      const ext = extname(ref);
      if ((ext === ".ts" || ext === ".js" || ext === ".py" || ext === ".sh") && ref.includes("/")) {
        const fid = nid("file", ref);
        g.addNode({ id: fid, label: ref, type: "file" });
        g.addEdge({ source: srcNid, target: fid, label: ref, type: "reads" });
      }
    }

    // sibling mentions in description
    const own = srcNid.split(":", 2)[1];
    for (const sib of knownSkills) {
      if (sib === own) continue;
      if (new RegExp(`\\b/${escapeRe(sib)}\\b`).test(fm.description || "")) {
        g.addEdge({ source: srcNid, target: nid("skill", sib), label: "mentions", type: "reads" });
      }
    }
  };

  for (const s of skills) {
    const name = s.fm.name || basename(dirname(s.path));
    processBody(nid("skill", name), s.fm, s.body);
  }
  for (const c of commands) {
    const name = c.namespace + (c.fm.name || basename(c.path, extname(c.path)));
    processBody(nid("command", name), c.fm, c.body);
  }
  for (const a of agents) {
    const name = a.fm.name || basename(a.path, extname(a.path));
    processBody(nid("agent", name), a.fm, a.body);
  }

  // --- Synthetic Claude hub ---
  const hubId = nid("root", "claude");
  g.addNode({ id: hubId, label: "Claude", type: "root", desc: "Host — invokes all registered skills, commands, and agents." });
  for (const k of g.nodes.keys()) {
    if (k === hubId) continue;
    if (k.startsWith("skill:") || k.startsWith("command:") || k.startsWith("agent:")) {
      g.addEdge({ source: hubId, target: k, label: "registers", type: "registers" });
    }
  }

  // --- Hooks from settings ---
  for (const p of settings) {
    let data: any = {};
    try { data = JSON.parse(await readSafe(p)); } catch { continue; }
    const hooks = data.hooks || {};
    if (!hooks || typeof hooks !== "object") continue;
    for (const [event, entries] of Object.entries(hooks)) {
      if (!Array.isArray(entries)) continue;
      entries.forEach((entry: any, i: number) => {
        if (!entry || typeof entry !== "object") return;
        const hid = nid("hook", `${event}#${i}`);
        g.addNode({
          id: hid, label: event, type: "hook",
          desc: JSON.stringify(entry).slice(0, 200), path: p,
        });
        for (const h of entry.hooks || []) {
          const cmd: string = h?.command || "";
          const m = /[\w\-/]+\.(?:sh|py|ts|js)/.exec(cmd);
          if (m) {
            const ref = m[0];
            const fid = nid("file", ref);
            g.addNode({ id: fid, label: ref, type: "file" });
            g.addEdge({ source: hid, target: fid, label: "runs", type: "triggers" });
          }
        }
      });
    }
  }

  return g;
}

function escapeRe(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

async function mergeSemanticSidecar(g: Graph, path: string): Promise<number> {
  if (!existsSync(path)) return 0;
  let data: any;
  try { data = JSON.parse(await readFile(path, "utf8")); } catch { return 0; }
  const edges = Array.isArray(data) ? data : Array.isArray(data?.edges) ? data.edges : [];
  let added = 0;
  for (const e of edges) {
    if (!e?.source || !e?.target) continue;
    if (!g.nodes.has(e.source) || !g.nodes.has(e.target)) continue;
    g.addEdge({
      source: e.source, target: e.target,
      label: e.label || "semantic", type: "semantic",
    });
    added++;
  }
  return added;
}

// ---------------------------------------------------------------------------
// HTML rendering
// ---------------------------------------------------------------------------

const HTML_TEMPLATE = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Skills Map</title>
<style>
  html, body { margin: 0; padding: 0; height: 100%; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background: #0e1116; color: #e6edf3; }
  #app { display: grid; grid-template-columns: 260px 1fr; height: 100vh; }
  #side { padding: 14px 16px; border-right: 1px solid #262c36; overflow-y: auto; }
  #cy { width: 100%; height: 100%; background: #0e1116; }
  h1 { font-size: 15px; margin: 0 0 12px; }
  h2 { font-size: 12px; text-transform: uppercase; letter-spacing: 0.05em; color: #8b949e; margin: 18px 0 6px; }
  label { display: flex; align-items: center; gap: 6px; font-size: 13px; padding: 2px 0; cursor: pointer; }
  .swatch { display: inline-block; width: 12px; height: 12px; border-radius: 3px; }
  .line { display: inline-block; width: 20px; height: 0; vertical-align: middle; }
  input[type=search] { width: 100%; box-sizing: border-box; padding: 6px 8px; background: #161b22; border: 1px solid #30363d; color: #e6edf3; border-radius: 4px; font-size: 13px; }
  #info { font-size: 12px; color: #8b949e; margin-top: 12px; line-height: 1.4; }
  #detail { position: absolute; right: 16px; top: 16px; max-width: 360px; padding: 10px 12px; background: rgba(22,27,34,0.95); border: 1px solid #30363d; border-radius: 6px; font-size: 12px; line-height: 1.5; display: none; }
  #detail h3 { margin: 0 0 6px; font-size: 13px; }
  #detail .kv { color: #8b949e; }
  #stats { font-size: 11px; color: #6e7681; margin-top: 8px; }
  button { background: #161b22; border: 1px solid #30363d; color: #e6edf3; padding: 4px 8px; border-radius: 4px; font-size: 12px; cursor: pointer; margin-top: 6px; }
  button:hover { background: #1f242c; }
</style>
<script src="https://unpkg.com/cytoscape/dist/cytoscape.min.js"></script>
<script src="https://unpkg.com/layout-base/layout-base.js"></script>
<script src="https://unpkg.com/cose-base/cose-base.js"></script>
<script src="https://unpkg.com/cytoscape-fcose/cytoscape-fcose.js"></script>
</head>
<body>
<div id="app">
  <div id="side">
    <h1>Skills Map</h1>
    <input id="search" type="search" placeholder="Search nodes…" />
    <h2>Node types</h2>
    <div id="nodeFilters"></div>
    <h2>Edge types</h2>
    <div id="edgeFilters"></div>
    <h2>Layout</h2>
    <label style="margin-bottom:6px"><input id="hideExternal" type="checkbox" checked /> Hide external deps</label>
    <button id="relayout">Re-run layout</button>
    <button id="fit">Fit to view</button>
    <div id="stats"></div>
    <div id="info">Click a node to see details. Hover edges for labels. Drag nodes to arrange.</div>
  </div>
  <div id="cy"></div>
</div>
<div id="detail"></div>
<script>
const DATA = __GRAPH_DATA__;

const NODE_COLORS = {
  root: "#e6edf3",
  skill: "#58a6ff", command: "#3fb950", agent: "#d2a8ff",
  plugin: "#f0883e", marketplace: "#ffa657", mcp: "#ff7b72",
  bin: "#8b949e", file: "#6e7681", hook: "#ffdf5d",
};
const NODE_SHAPES = {
  root: "ellipse",
  skill: "round-rectangle", command: "round-diamond", agent: "round-triangle",
  plugin: "round-hexagon", marketplace: "round-octagon", mcp: "round-pentagon",
  bin: "ellipse", file: "rectangle", hook: "star",
};
const EXTERNAL_TYPES = new Set(["bin", "file", "mcp", "hook"]);
const EDGE_STYLES = {
  references:    { color: "#58a6ff", style: "solid" },
  invokes:       { color: "#3fb950", style: "solid" },
  "companion-of":{ color: "#d2a8ff", style: "dashed" },
  "depends-on":  { color: "#f0883e", style: "solid" },
  reads:         { color: "#6e7681", style: "dotted" },
  owns:          { color: "#ffa657", style: "solid" },
  triggers:      { color: "#ffdf5d", style: "dashed" },
  registers:     { color: "#30363d", style: "solid" },
  semantic:      { color: "#bc8cff", style: "dashed" },
};

const elements = [];
for (const n of DATA.nodes) elements.push({ data: { ...n } });
for (const e of DATA.edges) elements.push({ data: { ...e, id: \`\${e.source}->\${e.target}#\${e.type}\` } });

const cy = cytoscape({
  container: document.getElementById("cy"),
  elements,
  wheelSensitivity: 0.3,
  style: [
    {
      selector: "node",
      style: {
        "background-color": (ele) => NODE_COLORS[ele.data("type")] || "#8b949e",
        "shape": (ele) => NODE_SHAPES[ele.data("type")] || "ellipse",
        "label": "data(label)",
        "color": "#e6edf3", "font-size": 11,
        "text-wrap": "wrap", "text-max-width": 120,
        "text-valign": "bottom", "text-margin-y": 4,
        "text-outline-color": "#0e1116", "text-outline-width": 2,
        "width": "mapData(degree, 0, 12, 36, 90)",
        "height": "mapData(degree, 0, 12, 36, 90)",
        "border-width": 1, "border-color": "#30363d",
      },
    },
    { selector: "node.faded", style: { "opacity": 0.12 } },
    { selector: "node.hit", style: { "border-color": "#ffdf5d", "border-width": 3 } },
    { selector: "node[type = 'root']", style: { "width": 90, "height": 90, "font-size": 14, "font-weight": "bold", "color": "#0e1116", "background-color": "#e6edf3", "border-color": "#58a6ff", "border-width": 3, "text-valign": "center", "text-margin-y": 0 } },
    {
      selector: "edge",
      style: {
        "width": 1.5,
        "line-color": (ele) => (EDGE_STYLES[ele.data("type")] || {}).color || "#6e7681",
        "line-style": (ele) => (EDGE_STYLES[ele.data("type")] || {}).style || "solid",
        "target-arrow-shape": "triangle",
        "target-arrow-color": (ele) => (EDGE_STYLES[ele.data("type")] || {}).color || "#6e7681",
        "curve-style": "bezier",
        "font-size": 9, "color": "#8b949e",
        "text-rotation": "autorotate",
        "text-background-color": "#0e1116",
        "text-background-opacity": 0.8,
        "text-background-padding": 2,
        "opacity": 0.75,
      },
    },
    { selector: "edge.faded", style: { "opacity": 0.05 } },
    {
      selector: "edge:selected, edge.highlight",
      style: { "width": 3, "opacity": 1, "label": "data(label)" },
    },
  ],
});

cy.nodes().forEach((n) => n.data("degree", n.degree()));

function runLayout() {
  const layout = cy.elements(":visible").layout({
    name: typeof cytoscapeFcose !== "undefined" ? "fcose" : "cose",
    animate: true, animationDuration: 500,
    nodeRepulsion: 14000, idealEdgeLength: 160,
    nodeSeparation: 90, gravity: 0.15,
    padding: 50, randomize: true,
    stop: () => cy.fit(cy.elements(":visible"), 50),
  });
  layout.run();
}

const detail = document.getElementById("detail");
cy.on("tap", "node", (evt) => {
  const n = evt.target;
  const d = n.data();
  detail.innerHTML = \`
    <h3>\${esc(d.label)}</h3>
    <div class="kv">type: \${esc(d.type || "")}</div>
    \${d.path ? \`<div class="kv">path: \${esc(d.path)}</div>\` : ""}
    \${d.tools ? \`<div class="kv">tools: \${esc(d.tools)}</div>\` : ""}
    \${d.desc ? \`<div style="margin-top:8px">\${esc(d.desc)}</div>\` : ""}
  \`;
  detail.style.display = "block";
  if (hideExternalEl.checked) {
    n.neighborhood("node").forEach((nb) => {
      if (isExternal(nb.data("type"))) revealed.add(nb.id());
    });
    applyFilters();
  }
});
cy.on("tap", (evt) => {
  if (evt.target === cy) {
    detail.style.display = "none";
    if (revealed.size > 0) { revealed.clear(); applyFilters(); }
  }
});
function esc(s) {
  return String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));
}
cy.on("mouseover", "edge", (e) => e.target.addClass("highlight"));
cy.on("mouseout", "edge", (e) => e.target.removeClass("highlight"));

const nodeTypes = [...new Set(DATA.nodes.map((n) => n.type))].sort();
const edgeTypes = [...new Set(DATA.edges.map((e) => e.type))].sort();
const nodeToggle = {}, edgeToggle = {};
function buildFilters(container, types, colors, isEdge) {
  const toggle = isEdge ? edgeToggle : nodeToggle;
  types.forEach((t) => {
    toggle[t] = true;
    const lbl = document.createElement("label");
    const cb = document.createElement("input");
    cb.type = "checkbox"; cb.checked = true;
    cb.addEventListener("change", () => { toggle[t] = cb.checked; applyFilters(); });
    const sw = document.createElement("span");
    sw.className = isEdge ? "line" : "swatch";
    if (isEdge) {
      const style = EDGE_STYLES[t] || {};
      sw.style.borderTop = \`2px \${style.style || "solid"} \${style.color || "#8b949e"}\`;
    } else {
      sw.style.background = colors[t] || "#8b949e";
    }
    lbl.appendChild(cb); lbl.appendChild(sw);
    lbl.appendChild(document.createTextNode(" " + t));
    container.appendChild(lbl);
  });
}
buildFilters(document.getElementById("nodeFilters"), nodeTypes, NODE_COLORS, false);
buildFilters(document.getElementById("edgeFilters"), edgeTypes, null, true);

const hideExternalEl = document.getElementById("hideExternal");
const revealed = new Set();
function isExternal(t) { return EXTERNAL_TYPES.has(t); }
function nodeShouldShow(n) {
  const t = n.data("type");
  if (!nodeToggle[t]) return false;
  if (hideExternalEl.checked && isExternal(t) && !revealed.has(n.id())) return false;
  return true;
}
function applyFilters() {
  cy.batch(() => {
    cy.nodes().forEach((n) => n.style("display", nodeShouldShow(n) ? "element" : "none"));
    cy.edges().forEach((e) => {
      const ok = edgeToggle[e.data("type")]
        && e.source().visible() && e.target().visible();
      e.style("display", ok ? "element" : "none");
    });
  });
}
hideExternalEl.addEventListener("change", () => {
  if (hideExternalEl.checked) revealed.clear();
  applyFilters();
  cy.fit(cy.elements(":visible"), 50);
});
document.getElementById("fit").addEventListener("click", () => cy.fit(cy.elements(":visible"), 50));

document.getElementById("search").addEventListener("input", (ev) => {
  const q = ev.target.value.trim().toLowerCase();
  cy.batch(() => {
    if (!q) { cy.elements().removeClass("faded hit"); return; }
    const hits = cy.nodes().filter((n) => {
      const d = n.data();
      return (d.label || "").toLowerCase().includes(q) || (d.desc || "").toLowerCase().includes(q);
    });
    cy.elements().addClass("faded");
    hits.removeClass("faded").addClass("hit");
    hits.neighborhood().removeClass("faded");
  });
});

document.getElementById("relayout").addEventListener("click", runLayout);
document.getElementById("stats").textContent = \`\${DATA.nodes.length} nodes · \${DATA.edges.length} edges\`;

applyFilters();
runLayout();
</script>
</body>
</html>
`;

async function render(graph: Graph, out: string): Promise<void> {
  const data = { nodes: [...graph.nodes.values()], edges: graph.edges };
  const html = HTML_TEMPLATE.replace("__GRAPH_DATA__", JSON.stringify(data));
  await writeFile(out, html, "utf8");
}

function openInBrowser(path: string): void {
  const cmd = platform === "darwin" ? "open"
    : platform === "win32" ? "cmd"
    : "xdg-open";
  const args = platform === "win32" ? ["/c", "start", "", path] : [path];
  const child = spawn(cmd, args, { detached: true, stdio: "ignore" });
  child.unref();
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

interface Args {
  roots: string[];
  out: string;
  open: boolean;
  semantic: string;
}

function parseArgs(av: string[]): Args {
  const roots: string[] = [];
  let out = "/tmp/skills-map.html";
  let open = true;
  let semantic = "/tmp/.skills-map-semantic.json";
  let i = 0;
  while (i < av.length) {
    const a = av[i];
    if (a === "--include" && av[i + 1]) { roots.push(resolve(av[++i])); i++; }
    else if (a === "--out" && av[i + 1]) { out = av[++i]; i++; }
    else if (a === "--semantic" && av[i + 1]) { semantic = av[++i]; i++; }
    else if (a === "--no-open") { open = false; i++; }
    else if (a === "-h" || a === "--help") {
      stdout.write("Usage: generate.ts [root] [--include PATH]... [--out PATH] [--semantic PATH] [--no-open]\n");
      exit(0);
    }
    else { roots.push(resolve(a)); i++; }
  }
  if (roots.length === 0) roots.push(resolve("."));
  return { roots, out: resolve(out), open, semantic: resolve(semantic) };
}

async function main(): Promise<void> {
  const args = parseArgs(argv.slice(2));
  const graph = await discover(args.roots);
  if (graph.nodes.size === 0) {
    stderr.write("No skill artifacts found in the given roots.\n");
    exit(1);
  }
  const semAdded = await mergeSemanticSidecar(graph, args.semantic);
  await render(graph, args.out);
  const semMsg = semAdded ? `, +${semAdded} semantic` : "";
  stdout.write(`Wrote ${args.out}  (${graph.nodes.size} nodes, ${graph.edges.length} edges${semMsg})\n`);
  if (args.open) openInBrowser(pathToFileURL(args.out).href);
}

main().catch((err) => {
  stderr.write(String(err?.stack || err) + "\n");
  exit(1);
});
