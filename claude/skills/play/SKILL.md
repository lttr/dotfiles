---
name: play
description: Open browser and test functionality with Playwright via playwright-cli. User-invoked only (disable-model-invocation). Trigger with /play [URL or what to test].
disable-model-invocation: true
allowed-tools: Bash(playwright-cli:*), Bash(npx playwright-cli:*), Bash(nr:*), Bash(pnpm:*), Bash(npm:*), Bash(lsof:*), Bash(curl:*), Bash(ps:*), Bash(pwd:*), Bash(cat:*), Bash(git:*), Read, Glob, Grep
---

# /play — Playwright browser test

Test functionality in a real browser via `playwright-cli`.

## Context gathering (run first)

Collect context before starting:

- `pwd` — working directory
- `cat package.json | grep -E '"dev"|"start"|"preview"' | head -3` — dev scripts
- `lsof -i :3000 -i :5173 -i :4000 -i :8080 -i :4173 2>/dev/null | grep LISTEN | head -3` — running dev server
- `git diff --name-only HEAD~1 | head -10` — recent changes

## Task

Drive `playwright-cli` to test in a real browser. Run `playwright-cli --help` if unsure about a flag.

**If arguments are empty:** infer what to test from recent git changes or conversation context.

**If arguments are a URL:** navigate directly, explore/test.

**If arguments are a description:** use as test instructions.

### Steps

1. **Start browser** — `playwright-cli open --headed` (or `... --headed <url>`). Omit `--headed` only if arguments contain "headless".
2. **Start dev server if needed** — if testing localhost and no server running, start in background with `nr dev` or `nr start`.
3. **Navigate** to the relevant page.
4. **Test** — interact via `playwright-cli snapshot` → `click` / `fill` by ref.
5. **Verify** — check expected text, elements, state changes, console errors (`playwright-cli console`), network (`playwright-cli network`).
6. **Report** — what tested, what passed, issues found.

### Guidelines

- Snapshot frequently to understand state.
- Check console after interactions.
- `playwright-cli screenshot` when something looks wrong.
- Test happy path + obvious edge cases.
- Focused, not exhaustive.
