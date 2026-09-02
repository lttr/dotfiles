// In-page agent bridge: a floating widget that lets the human point at things
// and send them to the agent. Injected over CDP, so it needs no cooperation
// from the app — everything lives in a shadow root and the only globals are
// `window.__bridge` and the host element.
//
// Adding an action is one entry in ACTIONS; nothing else knows the list.
;(() => {
  if (window.__bridge) return window.__bridge.show()

  const SINK = new URL(".", document.currentScript.src).href
  const host = document.createElement("div")
  host.id = "__agent-page-bridge"
  host.style.cssText = "position:fixed;inset:0;pointer-events:none;z-index:2147483647"
  const root = host.attachShadow({ mode: "open" })

  // ---------------------------------------------------------------- transport

  async function send(action, payload) {
    // text/plain keeps this a CORS "simple request": no preflight, so it works
    // against any dev origin without the sink having to guess it.
    try {
      await fetch(`${SINK}event`, {
        method: "POST",
        headers: { "content-type": "text/plain" },
        body: JSON.stringify({ action, url: location.href, title: document.title, payload }),
      })
      flash(`sent: ${action}`)
    } catch (err) {
      flash(`failed to reach bridge at ${SINK}`, true)
      console.error("[page-bridge]", err)
    }
  }

  // ------------------------------------------------------------- element info

  function cssPath(el) {
    if (el.id) return `#${CSS.escape(el.id)}`
    const parts = []
    for (; el && el !== document.body; el = el.parentElement) {
      let s = el.tagName.toLowerCase()
      if (el.classList.length) s += `.${[...el.classList].map(CSS.escape).join(".")}`
      const sibs = [...el.parentNode.children].filter((c) => c.tagName === el.tagName)
      if (sibs.length > 1) s += `:nth-of-type(${sibs.indexOf(el) + 1})`
      parts.unshift(s)
    }
    return parts.join(" > ")
  }

  function describe(el) {
    const r = el.getBoundingClientRect()
    const cs = getComputedStyle(el)
    const attrs = [...el.attributes]
    return {
      selector: cssPath(el),
      tag: el.tagName.toLowerCase(),
      id: el.id || null,
      classes: [...el.classList],
      // Scoped-style ids (`data-v-*`) and test ids are the fastest route from a
      // pixel back to a source file, so they are called out separately.
      dataAttrs: attrs.filter((a) => a.name.startsWith("data-")).map((a) => (a.value ? `${a.name}="${a.value}"` : a.name)),
      attrs: attrs.slice(0, 16).map((a) => `${a.name}="${a.value}"`),
      text: (el.textContent || "").trim().slice(0, 300),
      html: el.outerHTML.slice(0, 800),
      box: { x: Math.round(r.x), y: Math.round(r.y), w: Math.round(r.width), h: Math.round(r.height) },
      styles: {
        display: cs.display,
        gap: cs.gap,
        margin: cs.margin,
        padding: cs.padding,
        font: `${cs.fontSize}/${cs.lineHeight} ${cs.fontWeight}`,
        color: cs.color,
        background: cs.backgroundColor,
      },
    }
  }

  // ---------------------------------------------------------------------- ui

  root.innerHTML = `
    <style>
      * { box-sizing: border-box; }
      .fab, .panel, .toast, .prompt { pointer-events: auto; font: 12px/1.5 system-ui, sans-serif; color: #fff; }
      .fab, .panel, .prompt, .toast { background: #111827; box-shadow: 0 4px 14px #0005; }
      .fab { position: fixed; right: 16px; bottom: 16px; display: flex; align-items: center; gap: 6px;
             padding: 8px 12px; border: 0; border-radius: 999px; cursor: grab; user-select: none; }
      .fab:active { cursor: grabbing; }
      .fab .dot { width: 7px; height: 7px; border-radius: 50%; background: #34d399; }
      .panel { position: fixed; right: 16px; bottom: 60px; width: 220px; padding: 6px; border-radius: 10px; }
      .panel button { display: block; width: 100%; text-align: left; padding: 7px 10px; border: 0; border-radius: 6px;
                      background: transparent; color: inherit; cursor: pointer; font: inherit; }
      .panel button:hover { background: #ffffff1f; }
      .panel .hint { padding: 4px 10px 6px; color: #9ca3af; font-size: 11px; }
      .box { position: fixed; pointer-events: none; background: #0096ff40; border: 2px solid #09f; }
      .tip { position: fixed; pointer-events: none; background: #09f; color: #fff; padding: 2px 6px;
             border-radius: 3px; max-width: 60vw; font: 11px/1.4 ui-monospace, monospace; }
      .banner { position: fixed; inset-inline: 0; bottom: 0; pointer-events: none; text-align: center;
                background: #111827; color: #fff; padding: 3px 10px; font: 12px/1.7 ui-monospace, monospace; }
      .toast { position: fixed; right: 16px; bottom: 60px; padding: 6px 10px; border-radius: 6px; background: #065f46; }
      .toast.err { background: #7f1d1d; }
      .prompt { position: fixed; right: 16px; bottom: 60px; width: 260px; padding: 10px; border-radius: 10px; }
      .prompt textarea { width: 100%; height: 70px; margin: 6px 0; padding: 6px; resize: vertical; font: inherit;
                         border: 1px solid #374151; border-radius: 6px; background: #0b1220; color: #fff; }
      .prompt .row { display: flex; gap: 6px; justify-content: flex-end; }
      .prompt button { padding: 5px 10px; border: 0; border-radius: 6px; cursor: pointer; font: inherit; color: #fff; }
      .prompt .ok { background: #2563eb; }
      .prompt .cancel { background: #374151; }
      [hidden] { display: none !important; }
    </style>
    <button class="fab"><span class="dot"></span>agent</button>
    <div class="panel" hidden></div>`
  const fab = root.querySelector(".fab")
  const panel = root.querySelector(".panel")
  document.documentElement.append(host)

  const el = (cls, text = "") => {
    const d = document.createElement("div")
    d.className = cls
    d.textContent = text
    root.append(d)
    return d
  }

  function flash(msg, isError = false) {
    const t = el(`toast${isError ? " err" : ""}`, msg)
    setTimeout(() => t.remove(), isError ? 4000 : 1800)
  }

  function askText(question) {
    return new Promise((resolve) => {
      const p = el("prompt")
      p.innerHTML = `<div></div><textarea></textarea>
        <div class="row"><button class="cancel">Cancel</button><button class="ok">Send</button></div>`
      p.firstElementChild.textContent = question
      const ta = p.querySelector("textarea")
      ta.focus()
      const done = (ok) => {
        p.remove()
        resolve((ok && ta.value.trim()) || null)
      }
      p.querySelector(".ok").onclick = () => done(true)
      p.querySelector(".cancel").onclick = () => done(false)
      // Enter sends, Shift+Enter breaks the line.
      ta.onkeydown = (e) => {
        e.stopPropagation()
        if (e.key === "Enter" && !e.shiftKey) (e.preventDefault(), done(true))
        else if (e.key === "Escape") done(false)
      }
    })
  }

  // -------------------------------------------------------------- the picker

  // Resolves to one element, an array (multi mode), or null when cancelled.
  // Events inside the shadow root retarget to the host, so one identity check
  // keeps the toolbar itself unpickable.
  function pick({ multi = false } = {}) {
    return new Promise((resolve) => {
      const box = el("box")
      const tip = el("tip")
      const banner = el("banner")
      const legend = multi ? "ctrl/⌘+click = add · Enter = finish · Esc = cancel" : "click an element · Esc = cancel"
      banner.textContent = legend
      fab.hidden = panel.hidden = true
      const chosen = []
      const marked = []

      const finish = (value) => {
        for (const type in handlers) document.removeEventListener(type, handlers[type], true)
        for (const m of marked) m.el.style.outline = m.prev
        box.remove(), tip.remove(), banner.remove()
        fab.hidden = false
        resolve(value)
      }

      const handlers = {
        mousemove(e) {
          const t = e.target
          if (t === host) return
          const r = t.getBoundingClientRect()
          Object.assign(box.style, { top: `${r.top}px`, left: `${r.left}px`, width: `${r.width}px`, height: `${r.height}px` })
          tip.textContent = t.tagName.toLowerCase() + (t.id ? `#${t.id}` : "") + [...t.classList].map((c) => `.${c}`).join("")
          Object.assign(tip.style, { top: `${Math.max(0, r.top - 20)}px`, left: `${r.left}px` })
        },
        click(e) {
          const t = e.target
          if (t === host) return
          e.preventDefault(), e.stopPropagation()
          if (!multi) return finish(describe(t))
          chosen.push(describe(t))
          marked.push({ el: t, prev: t.style.outline })
          t.style.outline = "3px solid #f0f"
          banner.textContent = `${chosen.length} selected · ${legend}`
        },
        keydown(e) {
          if (e.key === "Escape") (e.preventDefault(), finish(null))
          else if (e.key === "Enter" && multi && chosen.length) (e.preventDefault(), finish(chosen))
        },
      }
      for (const type in handlers) document.addEventListener(type, handlers[type], true)
    })
  }

  // ------------------------------------------------------------------ actions

  const ACTIONS = [
    {
      id: "pick",
      label: "Pick an element",
      async run() {
        const one = await pick()
        if (one) send("pick", one)
      },
    },
    {
      id: "pick-multi",
      label: "Pick several elements",
      async run() {
        const items = await pick({ multi: true })
        if (items?.length) send("pick-multi", { items })
      },
    },
    {
      id: "annotate",
      label: "Comment on an element",
      async run() {
        const one = await pick()
        const note = one && (await askText("What should change here?"))
        if (note) send("annotate", { ...one, note })
      },
    },
    {
      id: "note",
      label: "Send a note",
      async run() {
        const note = await askText("Message for the agent")
        if (note) send("note", { note })
      },
    },
    {
      id: "viewport",
      label: "Send viewport + scroll",
      run: () => send("viewport", { width: innerWidth, height: innerHeight, scrollY: Math.round(scrollY), dpr: devicePixelRatio }),
    },
  ]

  panel.innerHTML =
    ACTIONS.map((a) => `<button data-id="${a.id}">${a.label}</button>`).join("") +
    `<div class="hint">events stream to the agent at ${SINK}</div>`
  panel.onclick = (e) => {
    const id = e.target.closest("button")?.dataset.id
    if (!id) return
    panel.hidden = true
    ACTIONS.find((a) => a.id === id).run()
  }

  // A drag and a click share the same button; any movement makes it a drag,
  // otherwise moving the toolbar would always open the menu.
  let drag = null
  fab.onpointerdown = (e) => {
    const r = fab.getBoundingClientRect()
    drag = { dx: e.clientX - r.left, dy: e.clientY - r.top, moved: false }
    fab.setPointerCapture(e.pointerId)
  }
  fab.onpointermove = (e) => {
    if (!drag) return
    drag.moved = true
    const left = e.clientX - drag.dx
    const top = e.clientY - drag.dy
    Object.assign(fab.style, { left: `${left}px`, top: `${top}px`, right: "auto", bottom: "auto" })
    Object.assign(panel.style, { left: `${left}px`, top: `${top - 8}px`, right: "auto", bottom: "auto", transform: "translateY(-100%)" })
  }
  fab.onpointerup = () => {
    if (!drag.moved) panel.hidden = !panel.hidden
    drag = null
  }

  // Alt+P is the no-mouse route into the picker.
  document.addEventListener("keydown", (e) => {
    if (e.altKey && e.key.toLowerCase() === "p") (e.preventDefault(), ACTIONS[0].run())
  })

  // ------------------------------------------------------------- agent handle

  window.__bridge = {
    hide: () => (host.style.visibility = "hidden"),
    show: () => (host.style.visibility = "visible"),
    remove: () => (host.remove(), delete window.__bridge),
    send,
    pick,
    actions: ACTIONS.map((a) => a.id),
  }
})()
