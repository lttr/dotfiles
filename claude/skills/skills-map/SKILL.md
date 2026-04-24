---
name: skills-map
description: Scan current directory (recursively) for Claude Code skills, slash commands, agents, hooks, and plugin/MCP configs, then render an interactive HTML graph of their explicit and implicit relationships. Use when the user says "skills map", "skill graph", "visualize skills", "map skills", "how do my skills relate", or wants to audit a skill collection before publishing.
allowed-tools: Bash(node:*), Agent
argument-hint: [root] [--include PATH]... [--out PATH] [--semantic PATH] [--no-open] [--deep]
---

# Skills Map

Scan a directory tree for Claude Code skill artifacts and render an interactive graph (nodes = skills/commands/agents/hooks/MCPs/binaries; edges = labeled relations).

## Usage

Requires **Node 23.6+** (native TypeScript support, no flags or extra runtimes needed).

```bash
node <SKILL_DIR>/generate.ts [flags]
```

`<SKILL_DIR>` is the directory containing this SKILL.md.

Pass through any `$ARGUMENTS` the user provided. Flags:

- `root` (positional) — root to scan. Default: cwd.
- `--include PATH` — additional root (repeatable).
- `--out PATH` — output HTML path. Default: `/tmp/skills-map.html`.
- `--semantic PATH` — sidecar JSON of semantic edges (default `/tmp/.skills-map-semantic.json`). Loaded if present.
- `--no-open` — write file but don't open a browser.

After the script completes, print the output path. The script auto-opens the HTML in the default browser unless `--no-open`.

## What it detects

**Nodes** — `SKILL.md`, `commands/*.md`, `agents/*.md`, `plugin.json`, `marketplace.json`, `.mcp.json` servers, hook entries in `settings*.json`, external binaries and MCP tools referenced in `allowed-tools`.

**Edges**:
- `references` — `@path.md` inclusions in skill bodies
- `invokes` — skill/command body mentions `/other-skill`
- `companion-of` — reciprocal description phrases ("companion to /X")
- `depends-on` — `Bash(cmd:*)` entries and `mcp__server__tool` mentions
- `reads` — file path mentioned but not `@`-loaded
- `owns` — plugin/marketplace contains a skill/command
- `triggers` — hook entry references a command or script
- `registers` — synthetic edges from the `Claude` root node to every skill/command/agent (anchors orphans)
- `semantic` — logical links supplied via the `--semantic` sidecar (see below)

Scope: complete for internal regex-detectable relations, loose for external dependencies. Only the `semantic` edge type captures logical links that aren't present syntactically.

## Semantic edges (optional, via subagent)

The generator itself does no language understanding. To add logical relationships between skills (e.g. "X naturally follows Y even though neither mentions the other"), run an Explore-type subagent with `model: haiku` after the first generate pass:

1. Run `node generate.ts --no-open` once to produce the base graph.
2. Spawn an Agent: `subagent_type: Explore`, `model: haiku`. Prompt it to:
   - Read every `SKILL.md`, `commands/*.md`, and `agents/*.md` under the scan roots
   - Identify pairs of skills/commands/agents with a logical connection that the syntactic detectors would miss (workflow ordering, data handoff, topical overlap worth surfacing)
   - Write JSON to `./.skills-map-semantic.json` in the format:
     ```json
     { "edges": [
       { "source": "skill:plan-next", "target": "skill:implement-next",
         "label": "produces plan consumed by", "rationale": "plan-next writes files that implement-next reads" }
     ] }
     ```
   - Node IDs follow `<type>:<name>` — match exactly what's already in the graph (check the existing HTML's `DATA` blob or re-derive from file layout).
3. Re-run `node generate.ts` — the sidecar is auto-merged as `semantic`-typed edges (dashed purple).

The sidecar is idempotent and cached across runs; delete it to re-query.

## Notes

- Single TypeScript file. Node stdlib only, no npm installs.
- Output is one self-contained HTML file with a CDN reference to cytoscape.js + fcose layout.
- Safe to re-run; overwrites output file.
