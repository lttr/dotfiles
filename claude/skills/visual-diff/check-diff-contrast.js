// Sample every highlighted token against its actual background and report the worst
// contrast ratios. Covers rendered diffs (shadow DOM) and standalone .code blocks.
// Paste into the console on an open report, or run via a headless driver.
(() => {
  const cv = document.createElement("canvas"); cv.width = cv.height = 4;
  const cx = cv.getContext("2d");
  const px = (col, under) => {
    cx.clearRect(0, 0, 4, 4);
    if (under) { cx.fillStyle = under; cx.fillRect(0, 0, 4, 4); }
    cx.fillStyle = col; cx.fillRect(0, 0, 4, 4);
    const d = cx.getImageData(1, 1, 1, 1).data;
    return [d[0], d[1], d[2]];
  };
  const lum = ([r, g, b]) => {
    const f = (c) => (c /= 255) <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
  };
  const cr = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((m, n) => n - m); return (x + 0.05) / (y + 0.05); };
  const page = getComputedStyle(document.body).backgroundColor;
  const out = new Map();
  for (const c of document.querySelectorAll("diffs-container, .code")) {
    const root = c.shadowRoot || c;               // diffs render in a shadow root, code does not
    for (const s of root.querySelectorAll("span")) {
      if (s.textContent.trim().length < 2) continue;
      const stack = [];                       // every translucent layer under the token
      for (let e = s; e; e = e.parentElement || e.getRootNode().host) {
        const b = getComputedStyle(e).backgroundColor;
        if (b && b !== "rgba(0, 0, 0, 0)") stack.push(b);
      }
      let bg = page;
      for (const layer of stack.reverse()) bg = "rgb(" + px(layer, bg).join(",") + ")";
      const fgc = getComputedStyle(s).color;
      out.set(fgc + "|" + bg, cr(px(fgc), px(bg)));
    }
  }
  const rows = [...out].map(([k, v]) => [+v.toFixed(2), k]).sort((a, b) => a[0] - b[0]);
  return { worst: rows.slice(0, 6), failing: rows.filter((r) => r[0] < 4.5) };
})()
