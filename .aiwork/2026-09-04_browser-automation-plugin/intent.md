---
status: accepted
references:
  - "Prior migration: ../2026-06-01_pick-skill-agent-browser-migration/spec.md"
  - "Deprecated predecessor: ~/code/claude-marketplace/_archived/browser-tools/"
---

# Intent: move all agent automation into its own plugin

Move all agent automation into its own plugin.

Today it's spread across four places: `agent-browser`, `showme` and `page-bridge`
as personal skills in `~/dotfiles/claude/skills/`, `/pick` as a personal command,
and a second, already-diverged copy of the `agent-browser` skill inside the
`aiwork` plugin — where browser automation has nothing to do with the `.aiwork`
folder protocol.

Separately, and only once the plugin exists: decide whether the underlying CLI
stays `agent-browser` or becomes `@playwright/cli`. That question is what
started this; see `research.md`.

## Scope

**A piece belongs in the plugin if and only if it depends on the browser-driving
CLI** — the thing that would have to change in a `@playwright/cli` swap.

All four of these, and only these:

| Piece | Current location | Depends on |
| --- | --- | --- |
| `agent-browser` | `dotfiles/claude/skills/agent-browser/` **and** `marketplace/plugins/aiwork/skills/agent-browser/` (diverged fork) | is the wrapper itself |
| `showme` | `dotfiles/claude/skills/showme/` | `allowed-tools: Bash(agent-browser:*)`; refuses to fall back to another tool |
| `page-bridge` | `dotfiles/claude/skills/page-bridge/` | `bridge.mjs:47` shells out to it |
| `/pick` | `dotfiles/claude/commands/pick.md` | `allowed-tools` + every step |

Out, by the same test: `gv` (`Bash(gv:*)`) and `lavish` (`lavish-axi`) each ship
their own binary that owns its browser — a CLI swap wouldn't touch either file.
`ff` opens a file in Firefox. `scr`, `visual-diff` and `explain-diff-html` never
drive a browser.

## Boundaries

The install must not need a repair step. The predecessor plugin, `browser-tools`,
was archived for exactly that.

## Decisions (2026-09-05)

1. **The CLI is `@playwright/cli` (`playwright-cli` 0.1.19).** First drafted as
   "agent-browser stays" because it was already on PATH; overruled the same day.
   `playwright-cli` is a plain global npm install and launches the system
   Chrome by default on any OS, so usually no browser download is needed. The
   install-step concern is handled instead of avoided: every skill runs a
   portable `check.sh` first, which verifies the binary and a browser launch
   and prints the exact install command when either is missing. The
   `playwright-cli` skill itself is the official one from `@playwright/cli`,
   vendored verbatim (`vendor.sh` re-syncs it) with plugin notes appended, so
   installing the plugin needs no `playwright-cli install-skills` step.
2. **`/pick` and `page-bridge` stay separate.** This was a move, not a redesign:
   `pick` is the one-shot answer, `page-bridge` stays on the page and carries
   comments and notes. The plugin README says so, so a later merge has a home.
3. **The plugin is the only copy.** Dotfiles keep no stubs; a second copy is what
   produced the diverged fork.

## Outcome

Plugin `browser` in `~/code/claude-marketplace/plugins/browser/` with skills
`playwright-cli`, `showme`, `page-bridge`, `pick`, all driving `playwright-cli`
(`bridge.mjs` shells out to it; persistence is a runtime `addInitScript` via
`run-code`, so `keep` is gone; `pick` uses `attach --cdp` + `tab-select`). `/pick` moved from a command to
a skill (`/browser:pick`), body unchanged. Removed from dotfiles
(`claude/skills/{agent-browser,showme,page-bridge}`, `claude/commands/pick.md`)
and from the `aiwork` plugin. Registered in `marketplace.json`; READMEs and the
marketplace `CLAUDE.md` updated. Version left at `0.1.0` for `/release`.
