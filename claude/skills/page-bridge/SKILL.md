---
name: page-bridge
description: Put a floating "agent" toolbar on a running dev page so the human can point at elements, comment on them, or send notes, and have those arrive as live agent notifications. Use when iterating on a design or UI together in the browser, when the user asks for a picker or "let me show you which element", or says "page bridge". Project-agnostic — injected over CDP, needs no app code.
---

# Page bridge

A floating toolbar injected into any running dev page. The human clicks
elements or types a note; the agent gets notified with the selector, computed
styles, and surrounding HTML. Nothing is added to the project's source — the
widget is injected over CDP and disappears on reload.

## Pieces

| File         | Role                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------- |
| `bridge.mjs` | Node (>= 24) sink + driver: `serve` / `open` / `inject` / `keep` / `status` / `hide` / `show` / `log` / `stop` |
| `bridge.js`  | The in-page widget (shadow DOM, so it cannot collide with app styles)                       |

The sink's **stdout is the event stream** — one compact line per event. Run it
under a Monitor and every click in the page becomes a notification.

## Setup

The app must already be running and `agent-browser` attached to its page (in
this repo that is the `run-jedlik-nejedlik` skill; elsewhere, the `run` skill or
`agent-browser open --headed <url>`).

**1. Start the sink in a persistent Monitor** — this is what delivers events:

```bash
# Monitor tool, persistent: true, description: "page-bridge events"
~/.claude/skills/page-bridge/bridge.mjs serve
```

Every line it prints is an event notification. No filter needed; it only ever
emits events (startup and errors go to stderr).

**2. Put the widget on the page.** Prefer `open`, which registers the loader as
an init script so it re-installs itself on every reload and navigation:

```bash
~/.claude/skills/page-bridge/bridge.mjs open http://localhost:3000/
```

If the page is already open and holds state you do not want to lose (a filled
form, a logged-in session), inject into it instead — but this is one-shot, and
a dev-server reload wipes it:

```bash
~/.claude/skills/page-bridge/bridge.mjs inject
~/.claude/skills/page-bridge/bridge.mjs keep   # optional: re-inject after reloads
```

Then tell the user the toolbar is the pill in the bottom-right corner.

## What the user can do

Clicking the **agent** pill opens the menu; the pill is draggable.

- **Pick an element** — hover to highlight, click to send. `Alt+P` does the same
  without the menu.
- **Pick several elements** — ctrl/⌘+click to accumulate, `Enter` to send.
- **Comment on an element** — pick, then type what should change. This is the
  useful one during design review: the agent gets the selector *and* the intent.
- **Send a note** — freeform message, no element.
- **Send viewport + scroll** — for "it breaks at this width".

`Esc` cancels any pick.

## Reading events

The notification line is a summary. For the full record — computed styles,
`data-v-*` scope ids, 800 chars of `outerHTML`, the bounding box:

```bash
~/.claude/skills/page-bridge/bridge.mjs log 1 | jq .
```

Go from a picked element to source with its `dataAttrs`: a Vue `data-v-<hash>`
maps to exactly one SFC (`grep -rl 'data-v-<hash>'` against the build, or match
the class name), and `data-testid` usually names the component outright.

## Notes

- **Screenshots**: `bridge.mjs hide` before `agent-browser screenshot`, then
  `bridge.mjs show` — otherwise the toolbar is in the picture.
- The widget skips itself when picking, so its own buttons are never selectable.
- `BRIDGE_PORT` (default 7788) and `BRIDGE_DIR` (default `$TMPDIR/page-bridge`,
  holds `events.jsonl` and the loader) override the defaults; set them in the
  environment of both `serve` and the other subcommands.
- Injection uses a `<script>` tag. A dev server with a strict `script-src` CSP
  will block it — the console shows the violation and `inject` reports failure.
- The widget is re-fetched from the sink on every load, so editing `bridge.js`
  takes effect on the next page reload — nothing to re-register.
- `agent-browser` 0.35.1 has no runtime `addinitscript`, which is why persistence
  goes through `open --init-script`. If a later version adds it, `inject` can
  become persistent without reopening the page and `keep` can go.
- Adding an action is one entry in `ACTIONS` in `bridge.js`; the menu, the
  dispatch, and `window.__bridge.actions` all read from that list. Give
  `summarize()` in `bridge.mjs` a case for it so its notification line stays
  readable.
