# Handoff: migrate `/pick` skill to agent-browser + Chrome

**Date:** 2026-06-01
**File to change:** `~/dotfiles/claude/commands/pick.md`
**Why:** custom `browser-*` CLIs the skill depends on are no longer installed. `agent-browser` is the survivor.

## Problem (observed this session)

`/pick` assumes a `browser-tools` plugin CLI:
- `browser-start --profile` — launch Chrome on :9222
- `browser-pick "<prompt>"` — visual click-to-select picker (puppeteer-core)
- `browser-eval '<js>'` — eval in page

None are on PATH. Only `agent-browser` exists (`~/.vite-plus/bin/agent-browser`). The skill's frontmatter `allowed-tools` still whitelists the dead commands.

`agent-browser` has **no native element picker** — that's the core gap. Everything else maps cleanly.

## Current impl reference (browser-pick.js)

Source still readable at:
`~/.claude/plugins/cache/lttr-claude-marketplace/browser-tools/1.6.1/skills/browser-tools/scripts/browser-pick.js`

Feature set to preserve (parity target):
- connect to existing Chrome on :9222, operate on **last** tab
- hover highlight overlay + bottom banner
- single click → resolve one element
- Cmd/Ctrl+click → multi-select; Enter finishes; ESC cancels
- element info: `tag`, `id`, `class`, `text` (≤200ch), `html` (outerHTML ≤500ch), `parents` chain
- output as `key: value` lines

## agent-browser command map

| old | new |
|-----|-----|
| `browser-start --profile` | launch Chrome manually (see below) |
| connect (implicit, :9222) | `agent-browser connect <port>` |
| `browser-eval '<js>'` | `agent-browser eval '<js>'` |
| navigate | `agent-browser open <url>` |
| (none) | `agent-browser close --all` |

Verified commands: `connect`, `open`, `eval`, `close --all`, `screenshot`, `snapshot`.

### Launching Chrome (no browser-start)

```bash
# :9222 is often taken by Edge/Teams. Use a free port + dedicated profile.
google-chrome --remote-debugging-port=9223 \
  --user-data-dir="$HOME/.chrome-debug-profile" "<url>" >/dev/null 2>&1 &
# wait for CDP endpoint
until curl -s http://localhost:9223/json/version >/dev/null 2>&1; do sleep 0.3; done
```

### Gotcha: sticky session

`agent-browser` reuses its last session. After launching a new Chrome, a bare
`connect <port>` may still `eval` against the old target. Fix:

```bash
agent-browser close --all; sleep 1; agent-browser connect 9223
agent-browser eval 'location.href + " | " + document.title'   # confirm target
```

## The missing picker — inject + poll

Replace `browser-pick` with: inject a JS overlay that writes the result to
`window.__picked`, then poll via `eval`. Working version from this session
(single-select; extend for multi):

```js
(() => {
  if (window.__picker) return "already-armed";
  window.__picked = null;
  const box = document.createElement("div");
  box.style.cssText = "position:fixed;pointer-events:none;z-index:2147483647;background:rgba(0,150,255,.25);border:2px solid #09f;border-radius:2px;transition:all .03s;";
  const tip = document.createElement("div");
  tip.style.cssText = "position:fixed;pointer-events:none;z-index:2147483647;background:#09f;color:#fff;font:11px/1.4 monospace;padding:2px 6px;border-radius:3px;max-width:60vw;";
  document.body.append(box, tip);
  const sel = el => {
    if (el.id) return "#" + CSS.escape(el.id);
    const parts = [];
    while (el && el.nodeType === 1 && el !== document.body) {
      let s = el.tagName.toLowerCase();
      if (el.classList.length) s += "." + [...el.classList].map(c=>CSS.escape(c)).join(".");
      const sib = [...el.parentNode.children].filter(c=>c.tagName===el.tagName);
      if (sib.length>1) s += `:nth-of-type(${sib.indexOf(el)+1})`;
      parts.unshift(s); el = el.parentElement;
    }
    return parts.join(" > ");
  };
  const move = e => {
    const el = e.target, r = el.getBoundingClientRect();
    box.style.cssText += `;top:${r.top}px;left:${r.left}px;width:${r.width}px;height:${r.height}px;`;
    tip.textContent = el.tagName.toLowerCase() + (el.id?"#"+el.id:"") + (el.className&&typeof el.className==="string"?"."+el.className.trim().split(/\s+/).join("."):"");
    tip.style.top = Math.max(0,r.top-20)+"px"; tip.style.left = r.left+"px";
  };
  const click = e => {
    e.preventDefault(); e.stopPropagation();
    const el = e.target;
    window.__picked = {
      selector: sel(el), tag: el.tagName.toLowerCase(), id: el.id||null,
      classes: el.className && typeof el.className==="string" ? el.className.trim().split(/\s+/) : [],
      text: (el.textContent||"").trim().slice(0,120),
      attrs: [...el.attributes].map(a=>`${a.name}="${a.value}"`).slice(0,12)
    };
    document.removeEventListener("mousemove", move, true);
    document.removeEventListener("click", click, true);
    box.remove(); tip.remove(); window.__picker = false; return false;
  };
  document.addEventListener("mousemove", move, true);
  document.addEventListener("click", click, true);
  window.__picker = true; return "armed";
})()
```

Poll loop (background it; eval is one-shot):

```bash
for i in $(seq 1 120); do
  r=$(agent-browser eval 'window.__picked ? JSON.stringify(window.__picked) : ""' 2>/dev/null)
  r=${r#\"}; r=${r%\"}
  [ -n "$r" ] && [ "$r" != "null" ] && { echo "$r" | sed 's/\\"/"/g'; exit 0; }
  sleep 1
done
echo "TIMEOUT: no element picked in 120s"
```

This version generates a unique `selector` (the old impl did not — nice upgrade).
Missing vs old impl: multi-select (Cmd+click/Enter), ESC cancel, `html` field.
Add `keydown` handlers + a `selections[]` array to reach parity if wanted.

## Dev-server detection — fix the hardcoded assumptions

The skill hardcodes `localhost:3000` and a port list `3000/5173/4000/8080`.
For drmax-nsf-global this is wrong:
- dev server binds **127.0.0.1:8080** (not 3000), via `pnpm nsf dev`
- Host header drives locale — must navigate to `http://local.drmax.cz:8080/`,
  not `localhost:8080` (wrong host → SK fallback → 404). See memory `reference_dev_against_prod`.

Recommendation: detect the actual LISTEN port from `ss -tlnp` rather than probing
`localhost:3000`, and prefer a project-known hostname when one exists.

## Migration steps

1. Rewrite `pick.md` frontmatter `allowed-tools`:
   `Bash(agent-browser:*), Bash(google-chrome:*), Bash(curl:*), Bash(ss:*), Bash(seq:*), Read, Glob`
   (drop `browser-start|browser-nav|browser-pick|browser-eval`).
2. Context probes: replace `lsof -i :9222` Chrome check with a CDP ping
   (`curl -s localhost:9222/json/version`), and port detection with `ss -tlnp`.
3. Step 1 (Chrome): launch via `google-chrome --remote-debugging-port=<port> --user-data-dir=...`
   on a **free** port; wait for CDP; document the :9222-taken-by-Edge case.
4. Step 4 (pick): inject the overlay script above, then background-poll `window.__picked`.
5. Keep output contract: print `tag/id/classes/text` + a ready-to-use CSS selector.
6. Optionally extract the picker JS to a sibling script file so `pick.md` stays small.

## Open questions

1. **Multi-select needed?** Old impl had Cmd+click/Enter. Keep it, or single-pick only?
2. **Port policy:** always launch fresh Chrome on a free port, or reuse :9222 if a debuggable Chrome is already there?
3. **Profile:** dedicated `~/.chrome-debug-profile`, or `--profile`-equivalent reusing the real profile (logged-in sessions)?
4. **Generalize?** This is now drmax-aware (8080 + local.drmax.cz). Should the skill stay generic and read project hints from CLAUDE.md, or fork a project-specific variant?
5. **agent-browser native picker:** check `agent-browser skills get core --full` — confirm no built-in picker exists before committing to the inject+poll approach.
