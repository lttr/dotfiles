---
name: memory-promote
description: Audit auto-memory files for the current repo (or all projects) and suggest promoting each one to a more persistent layer — global/project CLAUDE.md, an existing or new skill, a settings.json hook, or a checked-in reference doc. Use when the user says "audit memory", "promote memory", "clean up memories", "memory-promote", or wants to move ephemeral memory into durable config.
allowed-tools: Bash(ls:*), Bash(fd:*), Bash(rg:*), Bash(cat:*), Bash(realpath:*), Bash(pwd:*), Read, Edit, Write
argument-hint: [--all|global] [--list] [--project <path>] [--apply]
---

# Memory Promote

Auto-memory under `~/.claude/projects/<encoded-cwd>/memory/` is per-conversation context, not durable config. Many memories belong in a more persistent layer where they apply consistently and survive memory pruning. This skill scans memories and proposes a target layer for each.

## Scope (default: current repo)

Project memory dirs use the cwd with `/` replaced by `-`:
- `/home/lukas/dotfiles` → `~/.claude/projects/-home-lukas-dotfiles/memory/`

**Default scope = current repo, always.** Flags only widen scope or change mode.

1. No flag → current repo, full classify+promote. Compute `MEM_DIR=~/.claude/projects/$(pwd | tr / -)/memory`. If missing, report "no memories for this repo" and stop.
2. `--project <path>` → use that path's encoded dir instead of cwd.
3. `--all` → widen scope to every `~/.claude/projects/*/memory/` dir, grouped by project.
4. `--list` (alias: bare word `list`) → surface-only mode (no suggestions, no edits). Still scopes to current repo by default. Combine with `--all` for cross-project flat overview, or `--project <path>` for a specific repo.

**Argument parsing is forgiving.** Treat these bare words as flag aliases:
- `list` → `--list`
- `all` → `--all` (every project, no filter)
- `global` → `--all --filter=cross-cutting` (every project, but only show memories whose promotion target is **not** a repo `CLAUDE.md` — i.e., `~/.claude/CLAUDE.md`, a global skill, or a hook). "Global" means not-repo-specific, not "all repos".
- `apply` → `--apply`
- A path-like token → `--project <token>`

Examples: `list global` = list cross-cutting candidates only; `list all` = list everything across projects.

The cross-cutting filter classifies each memory the same way as the promotion table, then keeps only those whose target is global (`~/.claude/CLAUDE.md`, existing/new skill, or settings.json hook). Drops anything whose target is a repo `CLAUDE.md`.

## Steps

1. **List memories.** `fd -t f -E MEMORY.md . $MEM_DIR` (one or many dirs). For each file, read frontmatter (`name`, `description`, `type`) and body.
2. **Classify each memory** using the table below.
3. **Render report** — one row per memory: file, type, current content (1-line summary), → suggested target, rationale, concrete action.
4. **Wait for user confirmation** before changing anything. If `--apply` was passed, still confirm per-item — promotion is a judgment call.
5. **On confirm:** perform the action (edit CLAUDE.md, invoke `/cc:skill-creator`, invoke `/update-config` for hooks, write reference doc), then **delete the memory file and its line in MEMORY.md**.

## Promotion targets

| Memory pattern | Promote to | Why |
|---|---|---|
| `type: user` (role, stack, voice, naming) | `~/.claude/CLAUDE.md` | Applies across all projects, not just one |
| `type: feedback` — stable preference, repo-specific | repo `CLAUDE.md` | Survives memory pruning, visible to teammates |
| `type: feedback` — "never run X" / "X is human-only" | `settings.json` PreToolUse deny hook (via `/update-config`) | Harness enforces; can't be forgotten |
| `type: feedback` — repeatable workflow ("always do X before Y") | new skill (via `/cc:skill-creator`) or hook | Skill makes it discoverable; hook makes it automatic |
| `type: project` — durable fact (versioning scheme, release flow) | repo `CLAUDE.md` | Onboarding context, not session state |
| `type: project` — current sprint/incident/deadline | **keep in memory** | Genuinely ephemeral — memory is right layer |
| `type: reference` — internal URL, dashboard, doc page | repo `CLAUDE.md` "References" section | Checked in, shared with team |
| Pattern matches an existing skill (e.g., kitty launch → `kt`, Czech holidays → `datetime-cz`) | point to existing skill, delete memory | Skill already encodes it |
| Build/test command quirks | repo `CLAUDE.md` "Development Workflow" | Lives next to the code that needs it |

## Heuristics

- **Cross-repo applicability test:** would this memory be useful in any other repo? → global `CLAUDE.md`. Only this one? → project `CLAUDE.md`.
- **Enforcement test:** is the memory a *prohibition* ("never run X")? → hook beats prose. Memory/CLAUDE.md is a request; a hook is a guarantee.
- **Existing-skill test:** before suggesting a new skill, grep `~/.claude/skills/` and any plugin skills for overlap. Prefer pointing to existing skill.
- **Ephemeral test:** does it name a person, sprint, date, or in-flight ticket? → leave in memory.

## Output format

Print a numbered list. Per item:

```
[N] <memory-file> (type: <type>)
    Current: "<one-line summary of body>"
    → Promote to: <target>
    Why: <one sentence>
    Action: <exact edit / command to run>
```

After list: ask "Which to promote? (numbers, `all`, or `none`)". Then act on selected items one at a time.

## Notes

- Don't auto-delete a memory unless its content is fully captured at the new location.
- When editing `CLAUDE.md`, append under an existing relevant section if one exists; only create new sections when needed.
- For hook proposals, defer the actual settings edit to `/update-config` — it knows the schema.
- For skill proposals, defer to `/cc:skill-creator` — it knows the SKILL.md format.
- After promotion: also remove the line from `MEMORY.md` index.
