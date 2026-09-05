# Research: what a `@playwright/cli` swap would cost

Exploration behind `intent.md`, done before the plugin idea existed. It answers
open question 2, and its file inventory is the map for the extraction itself.

## Versions checked

- `agent-browser` 0.35.1 — `~/.vite-plus/bin/agent-browser`, single binary via vite-plus
- `@playwright/cli` 0.1.19 — binary is `playwright-cli`; verified via
  `npx @playwright/cli@latest --help` and per-command `--help`. Ships its own
  agent skill at `playwright-core/lib/tools/skills/playwright-cli/SKILL.md`.

## Where browser automation lives now

| File | Depth | What it uses |
| --- | --- | --- |
| `dotfiles/claude/commands/pick.md` (175 ln) | **heaviest** | `allowed-tools: Bash(agent-browser:*)`, manual `/json` target hunting, `connect ws://…`, `close --all`, `eval` poll loop. Most of the file is a workaround for agent-browser's sticky/non-deterministic `connect`. |
| `dotfiles/claude/skills/agent-browser/SKILL.md` (51 ln) | total | The skill *is* agent-browser. ~30 lines are the `screenshot --full-page` footgun + relative-path-vs-daemon-cwd warning. |
| `dotfiles/claude/skills/page-bridge/bridge.mjs` (208 ln) | real code, 2 call sites | `ab("eval", js)` → `JSON.parse` (~line 54); `ab("open","--headed","--init-script",loader,url)` (~line 149). |
| `dotfiles/claude/skills/page-bridge/SKILL.md` | docs | Prereq table, `hide`/`show` around screenshot, the "0.35.1 has no runtime addinitscript" note. |
| `dotfiles/claude/skills/showme/SKILL.md` (48 ln) | delegating | `allowed-tools`, `open --headed --session showme`, `close --all`, `--profile Default`. Explicitly says not to fall back to another automation tool. |
| `marketplace/plugins/aiwork/skills/agent-browser/SKILL.md` | total | Diverged fork of the dotfiles skill (missing the screenshot section). |
| marketplace `README.md` (×2 lines), `.claude-plugin/marketplace.json` | strings | Name appears in descriptions. |

Nothing in `scripts/`, `bootstrap/`, or shell config touches it. Coupling is
**shallow but wide**: 7 files, one of which holds real code.

Scope test, applied: a piece is in scope iff it depends on the browser-driving
CLI. That is exactly the four rows above (`agent-browser`, `showme`,
`page-bridge`, `/pick`) plus the diverged fork.

Verified out by the same test — `gv` uses `Bash(gv:*)`/`Bash(vpx:*)`, `lavish`
uses `lavish-axi`, `ff` uses `Bash(firefox:*)`; each owns its own browser, so a
CLI swap touches none of them. `scr` reads PNGs from disk, `visual-diff` and
`explain-diff-html` emit HTML, `youtube-transcript` only passes
`--cookies-from-browser` to yt-dlp. None drive a browser.

## Command mapping (near-total)

```
open <url>              → open <url> [--headed]     # playwright-cli is headless by default
snapshot -i             → snapshot                  # refs are `e15`, not `@e1`
click @e1 / fill @e2 x  → click e1 / fill e2 x
eval <js>               → eval <js>                 # expression, or (el)=>… with a ref arg
screenshot --full /p    → screenshot --full-page --filename=/p
connect <port|url>      → attach --cdp <url>
close --all             → close-all
--session <n>           → -s=<n>  (global flag)
--profile <dir>         → open --persistent --profile <dir>
read                    → (none) — use snapshot, or eval document.body.innerText
```

## Three real gaps

1. **No `--init-script` on `open`.** page-bridge's whole persistence mechanism.
   Replacement: `run-code "async page => { await page.addInitScript({content: LOADER}); await page.goto(url) }"`
   — arguably cleaner, and it retires the `keep` subcommand and the version note.
2. **`eval` output shape — UNVERIFIED.** `bridge.mjs` does `JSON.parse(ab("eval", js))`.
   playwright-cli wraps responses with status/code unless `--raw` / `--json` is
   passed. No live browser was run. **Test this first.**
3. **Distribution — and this is the one that matters.** agent-browser is already
   on PATH via vite-plus. playwright-cli needs `npm i -g @playwright/cli` plus
   `playwright-cli install-browser`. That is precisely the failure mode the
   archived `browser-tools` plugin was deprecated for: *"the setup step (npm
   dependencies + global symlinks) had to be re-run periodically — dependencies
   would go missing or the setup would drift."* Repeating it inside a new plugin
   would repeat the outcome.

## What Playwright would gain

`console`, `requests` / `response-body`, `route` mocking, `tracing-*`, `video-*`,
`recording-start` (codegen), `generate-locator`, `highlight`, `tab-list` /
`tab-select`, `state-save` / `state-load` for auth, `--device` emulation,
Firefox/WebKit, `--json` / `--raw` structured output, `attach --extension` to
drive the real logged-in Chrome.

Two documented footguns disappear: the `--full-page` positional-fallthrough trap
and the daemon-cwd relative-path trap. `tab-select` + `attach --cdp` remove the
reason `pick.md` pins a WS target by hand (~60 lines).

Neither CLI has a native element picker. `pick.md`'s injected JS overlay and poll
loop survive either way (`highlight` is display-only).

## Effort, if the swap happens

| Task | Effort |
| --- | --- |
| Rewrite the `agent-browser` skill → playwright-cli (one copy, post-extraction) | ~30 min; mostly deletion — the trap sections stop applying |
| `showme` — swap 4 commands | ~10 min |
| `bridge.mjs` — 2 call sites, `--raw` verification, `addInitScript` | ~1–2 h, needs live testing |
| `page-bridge` SKILL.md — prereq table + notes | ~20 min |
| `pick.md` — rewrite; overlay stays, CDP-pinning workaround goes | ~1–2 h |
| Install story (see gap 3) | unresolved — the real cost |
| README / marketplace.json strings | ~10 min |

~4–6 hours of mechanical work, risk concentrated in `bridge.mjs`, `pick.md`, and
the install.

## Constraints the extraction inherits

From the marketplace `CLAUDE.md`:

- `plugins/<name>/` with its own `.claude-plugin/plugin.json`; register in
  `.claude-plugin/marketplace.json`.
- Use `${CLAUDE_SKILL_DIR}` / `${CLAUDE_PLUGIN_ROOT}` — relative paths don't resolve.
  `bridge.mjs` and `bridge.js` are already invoked via `$CLAUDE_SKILL_DIR`.
- Never give a command and a skill the same name (bears on open question 3).
- Don't bump versions in feature commits; `/release` does that.
- Load `plugin-creator` and `skill-creator` when building it.
