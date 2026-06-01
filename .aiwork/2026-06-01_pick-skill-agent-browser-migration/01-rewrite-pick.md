---
status: complete
spec: spec.md
---

# Plan 01 — rewrite pick.md for agent-browser + Chrome

Single file: `~/dotfiles/claude/commands/pick.md`. Full rewrite.

## Decisions (resolved open questions)

1. Picker: **full parity** — multi-select (Ctrl/Cmd+click), Enter finishes, ESC cancels, single click = one-shot.
2. Port: **reuse :9222 if CDP answers, else launch fresh on next free port** (9223+).
3. Browser: **Chrome only**, dedicated `~/.chrome-debug-profile`. (Firefox = no CDP, can't attach.)
4. Generality: **generic** — detect LISTEN port via `ss -tlnp`; read optional dev host/port hint from project CLAUDE.md.
5. Picker JS: inline heredoc (no sibling file; symlink path resolution fragile).

## Changes

- **Frontmatter `allowed-tools`**: drop `browser-*`, `nr`, `pnpm`, `npm`, `lsof`, `ps`. Add:
  `Bash(agent-browser:*), Bash(google-chrome:*), Bash(curl:*), Bash(ss:*), Bash(seq:*), Bash(sleep:*), Bash(cat:*), Bash(vp:*), Read, Glob`
- **Context probes**:
  - dev server: `ss -tlnp` LISTEN ports (replace hardcoded :3000 list)
  - Chrome debug: `curl -s localhost:9222/json/version` CDP ping (replace `lsof :9222`)
  - dev hint: `grep` CLAUDE.md for a dev URL/port if present
- **Step 1 Chrome**: if CDP ping on 9222 succeeds → `agent-browser close --all; sleep 1; connect 9222`. Else launch `google-chrome --remote-debugging-port=9223 --user-data-dir=$HOME/.chrome-debug-profile`, wait for CDP, then `close --all; connect 9223`. Document :9222-taken-by-Edge case.
- **Step 2 dev server**: detect actual LISTEN port from `ss -tlnp`; prefer CLAUDE.md hint host; else `vp run dev` if package.json has dev/start, wait, navigate.
- **Step 3 navigate**: `agent-browser open <url>`; confirm target via `eval 'location.href + " | " + document.title'`.
- **Step 4 pick**: inject full-parity overlay (heredoc), then background-poll `window.__picked` via `eval` (120s timeout).
- **Step 5 output**: print `tag/id/classes/text` + unique CSS selector per element.

## Verification

- `head -1` frontmatter parses; no dead `browser-*` refs remain (`grep -c 'browser-start\|browser-pick\|browser-eval\|browser-nav'` = 0).
- `agent-browser` / `google-chrome` / `ss` / `curl` on PATH.
- Spot-check the overlay JS evaluates (no syntax error) via `node --check` on the extracted snippet.
