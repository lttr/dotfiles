---
allowed-tools: Bash(agent-browser:*), Bash(google-chrome:*), Bash(curl:*), Bash(ss:*), Bash(seq:*), Bash(sleep:*), Bash(cat:*), Bash(vp:*), Bash(grep:*), Read, Glob
description: Pick an element from the browser (starts dev server if needed)
argument-hint: [prompt]
---

## Context

- Current working directory: !`pwd`
- Package.json dev script (if exists): !`cat package.json 2>/dev/null | grep -E '"dev":|"start":' | head -2 || echo "No dev/start script"`
- Dev host/port hint (from CLAUDE.md, if any): !`grep -rhoE 'https?://[a-zA-Z0-9.-]+:[0-9]+' CLAUDE.md .claude/CLAUDE.md 2>/dev/null | sort -u | head -3 || echo "No CLAUDE.md dev URL hint"`
- LISTEN ports (candidate dev servers): !`ss -tlnH 2>/dev/null | awk '{print $4}' | grep -oE ':[0-9]+$' | tr -d ':' | sort -un | grep -vE '^(22|53|631)$' | head -10 || echo "none"`
- Debuggable browser on :9222 (Chrome OR Edge — both CDP): !`curl -s --max-time 1 http://localhost:9222/json/version 2>/dev/null | grep -oE '"Browser": *"[^"]*"' || echo "nothing on :9222"`

## Your task

Help the user pick an element from the browser. `agent-browser` drives any
Chromium browser over CDP (Chrome, Edge, Electron) — there is **no native
picker**, so we inject a JS overlay and poll for the result.

Critical gotcha: `agent-browser`'s `connect <port>` is sticky and picks a tab
non-deterministically — `eval` and `screenshot` can hit *different* tabs. So we
always connect to one **specific page target** by its WebSocket URL, and reset
sessions first.

**Step 1: Get a debuggable browser**

- **Reuse what's already on :9222** if the context shows one (the user's normal
  Chrome/Edge — best, keeps logged-in sessions). Skip to Step 1b.
- **Else launch a fresh Chrome.** Must be *detached* (`setsid … & disown`) or it
  dies when the command returns. `--ignore-certificate-errors --test-type`
  handles flaky dev TLS (e.g. self-signed `*.local` hosts). 9222 is often taken
  by Edge/Teams, so use a free port:
  ```bash
  setsid google-chrome --remote-debugging-port=9223 \
    --user-data-dir="$HOME/.chrome-debug-profile" \
    --ignore-certificate-errors --test-type "<start-url>" \
    </dev/null >/dev/null 2>&1 & disown
  until curl -s http://localhost:9223/json/version >/dev/null 2>&1; do sleep 0.3; done
  ```

**Step 1b: Pin to one page target + connect**

Pick the target page id from `/json` (the `type:"page"` whose url matches the
app — skip `service_worker`/`iframe`/`worker`), then connect by its WS URL:
```bash
PORT=9222   # or 9223 if you launched fresh
curl -s "http://localhost:$PORT/json" \
  | grep -B3 '"type": "page"' | grep -E '"(id|url)"'   # eyeball the right page id
TARGET=<that-id>
agent-browser close --all; sleep 1
agent-browser connect "ws://localhost:$PORT/devtools/page/$TARGET"
agent-browser eval 'location.href + " | " + document.title'   # confirm right tab
```

**Step 2: Find the page to pick from**

- Prefer the dev URL hint from CLAUDE.md (context above) — it carries the right
  host (some apps key locale/routing off the Host header, so `localhost` ≠ the
  project hostname).
- Else pick the dev server from the LISTEN ports above (ignore system ports).
- If nothing is listening AND package.json has a `dev`/`start` script, start it
  in the background and wait:
  ```bash
  vp run dev   # background it; wait until its port is LISTEN
  ```

**Step 3: Navigate**

```bash
agent-browser open "<dev-url>"
agent-browser eval 'location.href + " | " + document.title'   # confirm
```

**Step 4: Arm the picker overlay, then poll**

Inject the overlay (multi-select via Ctrl/Cmd+click, Enter finishes, single
click resolves one, ESC cancels):

```bash
agent-browser eval "$(cat <<'PICKER_JS'
(() => {
  if (window.__picker) return "already-armed";
  window.__picked = null; window.__pickerDone = false;
  const multi = [];
  const marks = [];   // {el, prevOutline} for restore on teardown
  const box = document.createElement("div");
  box.style.cssText = "position:fixed;pointer-events:none;z-index:2147483647;background:rgba(0,150,255,.25);border:2px solid #09f;border-radius:2px;transition:all .03s;";
  const tip = document.createElement("div");
  tip.style.cssText = "position:fixed;pointer-events:none;z-index:2147483647;background:#09f;color:#fff;font:11px/1.4 monospace;padding:2px 6px;border-radius:3px;max-width:60vw;";
  const banner = document.createElement("div");
  banner.style.cssText = "position:fixed;bottom:0;left:0;right:0;pointer-events:none;z-index:2147483647;background:#111;color:#fff;font:12px/1.6 monospace;padding:4px 10px;text-align:center;";
  banner.textContent = "click=pick · Ctrl/Cmd+click=add to multi · Enter=finish multi · Esc=cancel";
  document.body.append(box, tip, banner);
  const sel = el => {
    if (el.id) return "#" + CSS.escape(el.id);
    const parts = [];
    while (el && el.nodeType === 1 && el !== document.body) {
      let s = el.tagName.toLowerCase();
      if (el.classList.length) s += "." + [...el.classList].map(c=>CSS.escape(c)).join(".");
      const sib = [...el.parentNode.children].filter(c=>c.tagName===el.tagName);
      if (sib.length>1) s += ":nth-of-type(" + (sib.indexOf(el)+1) + ")";
      parts.unshift(s); el = el.parentElement;
    }
    return parts.join(" > ");
  };
  const info = el => ({
    selector: sel(el), tag: el.tagName.toLowerCase(), id: el.id||null,
    classes: el.className && typeof el.className==="string" ? el.className.trim().split(/\s+/).filter(Boolean) : [],
    text: (el.textContent||"").trim().slice(0,200),
    html: (el.outerHTML||"").slice(0,500),
    attrs: [...el.attributes].map(a=>a.name+"=\""+a.value+"\"").slice(0,12)
  });
  const teardown = () => {
    document.removeEventListener("mousemove", move, true);
    document.removeEventListener("click", click, true);
    document.removeEventListener("keydown", key, true);
    marks.forEach(m => { m.el.style.outline = m.prevOutline; });
    box.remove(); tip.remove(); banner.remove(); window.__picker = false;
  };
  const move = e => {
    const el = e.target, r = el.getBoundingClientRect();
    box.style.top=r.top+"px"; box.style.left=r.left+"px"; box.style.width=r.width+"px"; box.style.height=r.height+"px";
    tip.textContent = el.tagName.toLowerCase() + (el.id?"#"+el.id:"") + (el.className&&typeof el.className==="string"?"."+el.className.trim().split(/\s+/).join("."):"");
    tip.style.top = Math.max(0,r.top-20)+"px"; tip.style.left = r.left+"px";
  };
  const click = e => {
    e.preventDefault(); e.stopPropagation();
    const i = info(e.target);
    if (e.ctrlKey || e.metaKey) {
      multi.push(i);
      marks.push({el: e.target, prevOutline: e.target.style.outline});
      e.target.style.outline = "3px solid #f0f";   // persistent magenta marker
      banner.textContent = multi.length + " selected · Ctrl/Cmd+click=add more · Enter=finish · Esc=cancel";
      return false;
    }
    window.__picked = i; window.__pickerDone = true; teardown(); return false;
  };
  const key = e => {
    if (e.key === "Escape") { e.preventDefault(); window.__picked = {cancelled:true}; window.__pickerDone = true; teardown(); }
    else if (e.key === "Enter" && multi.length) { e.preventDefault(); window.__picked = {multi}; window.__pickerDone = true; teardown(); }
  };
  document.addEventListener("mousemove", move, true);
  document.addEventListener("click", click, true);
  document.addEventListener("keydown", key, true);
  window.__picker = true; return "armed";
})()
PICKER_JS
)"
```

Then poll (eval is one-shot, so loop):

```bash
for i in $(seq 1 120); do
  r=$(agent-browser eval 'window.__pickerDone ? JSON.stringify(window.__picked) : ""' 2>/dev/null)
  r=${r#\"}; r=${r%\"}
  [ -n "$r" ] && [ "$r" != "null" ] && { echo "$r" | sed 's/\\"/"/g'; break; }
  sleep 1
done
[ -z "$r" ] && echo "TIMEOUT: no element picked in 120s"
```

Use the user's prompt below to tell the user what to click before you start
polling.

**Step 5: Return results**

- If `cancelled`, report the user cancelled.
- For a single pick or each multi entry, show `tag` / `id` / `classes` / `text`
  and the ready-to-use CSS `selector`.

## User prompt (if any)

$ARGUMENTS
