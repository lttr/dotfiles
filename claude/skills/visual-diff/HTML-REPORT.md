# HTML Report Format

The walkthrough is a single HTML file. It embeds the **sources**, meaning Mermaid text,
hand-picked code, and raw git patches. The browser renders them with three ESM modules from
`esm.sh`:

- `beautiful-mermaid` for diagrams
- `shiki` for standalone code blocks
- `@pierre/diffs` for patches

There is no build step, no bundler, and no React. Nothing has to be regenerated when you
edit a diagram. Change the text and reload.

The cost is that the page needs network on open. In exchange, all code on the page is
highlighted token by token, diffs get word-level marks inside a line, selectable lines and
sticky headers, and the layout follows the viewport. If an import fails, each block falls
back to its raw source in a bordered `<pre>`, so an offline reader still sees the patch.

The palette and type follow lukastrumm.com:

- warm off-white or charcoal ground
- Solarized green, red, and indigo for the change colours
- Raleway headings over a Charter or Georgia serif body
- Fira Mono for code

Keep those tokens as they are. They are what makes the page look like Lukas's. Every pair
in them clears **WCAG AA** in both themes, meaning 4.5:1 for text and 3:1 for diagram
strokes and fills. If you retune a colour, re-run the check and fix what it flags.

```bash
python3 contrast.py <report>.html      # ships next to this file, exits non-zero on a fail
```

Highlighted code is a second, separate palette. Both highlighters use the Shiki themes
`github-light-high-contrast` and `github-dark-high-contrast`. `@pierre/diffs` themes its
code inside a shadow root, so the loader forces the surface, the add and del hues, and the
row tints back to the page tokens through `unsafeCSS`.

Those numbers are measured, not guessed. The dark surface is `#262223` rather than the card
colour, because a lighter well pushed the keyword red under 4.5:1. The `--code-bg` token
uses the same two values, so standalone code and diffs sit on the same well. Leave both
alone. If you must touch them, keep them equal and re-measure with
`check-diff-contrast.js`. Paste it into the console on the open report. It composites every
translucent layer and lists any pair under 4.5:1, in both themes.

Two layout rules hold the whole format together.

- **The page is fluid.** `main` fills the viewport up to a generous cap. Only prose is
  capped at a readable measure. A diagram pair on a 27" display gets two columns of roughly
  800px.
- **Diagrams upscale.** The loader stretches each SVG to its container, up to 1.8 times its
  intrinsic size. The text inside scales with it. Wide page, big diagrams, and big labels
  are the same decision. Clicking one opens it in a lightbox at up to 94vw, which is the
  escape hatch for a dense graph. The loader wires that up for every diagram, so do not
  hand-build a second one.

## Scaffold

```html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="stylesheet"
  href="https://fonts.googleapis.com/css2?family=Raleway:wght@500;600;700&display=swap" />
<title>Visual diff: {{short subject}}</title>
<style>

  :root {
    color-scheme: light dark;                        /* shiki's light-dark() rides on this */
    --bg:#fefcfc; --fg:#221f20; --muted:#6e6869; --rule:#e5dfdf; --card:#fff;
    --add:#5f6f00; --del:#c22e2b; --accent:#4040c4; --tint:#f7f1f2;
    --add-fill:#eef0dc; --del-fill:#fbe7e6; --accent-fill:#e9e9f9;
    --diagram-bg:#fefcfc; --diagram-fg:#3f3a3b;
    --code-bg:#fff;                                  /* keep equal to --diffs-light-bg */
    --serif:Charter,"Bitstream Charter","Iowan Old Style",Georgia,serif;
    --sans:Raleway,system-ui,-apple-system,"Segoe UI",sans-serif;
    --mono:"Fira Mono",ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --bg:#353132; --fg:#dfdddd; --muted:#aba6a6; --rule:#565051; --card:#3c3839;
      --add:#a8b833; --del:#f28a88; --accent:#9ea1ee; --tint:#3a3637;
      --add-fill:#39401a; --del-fill:#48282a; --accent-fill:#31315a;
      --diagram-bg:#353132; --diagram-fg:#cfcccc;
      --code-bg:#262223;                             /* keep equal to --diffs-dark-bg */
    }
  }
  * { box-sizing: border-box; }
  body { margin:0; padding:3.5rem clamp(1.25rem,3.5vw,3.5rem) 7rem;
         background:var(--bg); color:var(--fg);
         font:18px/1.7 var(--serif); }
  main { max-width:1800px; margin:0 auto; }          /* fluid, never a narrow column */
  h1,h2,h3 { font-family:var(--sans); font-weight:600; }
  h1 { font-size:2.4rem; line-height:1.15; margin:0 0 .5rem; letter-spacing:-.02em; }
  h2 { font-size:1.45rem; margin:4rem 0 1.1rem; letter-spacing:-.01em; }
  h3 { font-size:1.1rem; margin:2.2rem 0 .6rem; }
  p { margin:0 0 1rem; max-width:74ch; }             /* prose only, diagrams stay wide */
  .lede { font-size:1.25rem; line-height:1.5; max-width:80ch; }
  .meta { color:var(--muted); font:400 15px/1.5 var(--mono); }
  .ba { display:grid; grid-template-columns:1fr 1fr; gap:1.5rem; align-items:start; }
  .card { border:1px solid var(--rule); border-radius:12px; background:var(--card);
          padding:1.1rem 1.2rem 1.3rem; min-width:0; }
  .label { display:block; margin-bottom:.5rem; font:600 13px/1 var(--mono);
           letter-spacing:.09em; text-transform:uppercase; color:var(--muted); }
  .label.was { color:var(--del); } .label.now { color:var(--add); }
  .diagram { margin-top:.5rem; cursor:zoom-in; }
  .diagram svg { display:block; margin:0 auto; }
  .diagram:focus-visible { outline:2px solid var(--accent); outline-offset:6px; border-radius:8px; }
  dialog.lightbox { border:none; padding:1.5rem; background:var(--card); color:var(--fg);
                    border-radius:14px; box-shadow:0 24px 64px rgb(0 0 0 / 38%); }
  dialog.lightbox::backdrop { background:rgb(20 18 19 / 74%); }
  dialog.lightbox svg { display:block; width:min(94vw,2400px); height:auto;
                        max-height:88vh; cursor:zoom-out; }
  table { width:100%; border-collapse:collapse; font-size:17px; display:block; overflow-x:auto; }
  th { text-align:left; font:600 13px/1 var(--mono); letter-spacing:.09em;
       text-transform:uppercase; color:var(--muted); padding:0 1rem .6rem 0; white-space:nowrap; }
  td { padding:.65rem 1rem .65rem 0; border-top:1px solid var(--rule); vertical-align:top; }
  code, pre { font-family:var(--mono); }
  code { font-size:.92em; }
  pre { white-space:pre-wrap; overflow-x:auto; margin:0; padding:1rem 1.1rem;
        border:1px solid var(--rule); border-radius:10px; background:var(--card);
        font-size:16px; line-height:1.6; }
  pre.render-error { color:var(--del); border-color:var(--del); }
  /* Highlighted standalone code. The border carries was/now, never the text colour. */
  .code { border:1px solid var(--rule); border-radius:10px; background:var(--code-bg);
          overflow-x:auto; min-width:0; }
  .code.was { border-color:color-mix(in srgb,var(--del) 45%,var(--rule)); }
  .code.now { border-color:color-mix(in srgb,var(--add) 45%,var(--rule)); }
  .code pre { background:none !important; border:none; border-radius:0;
              white-space:pre; padding:1rem 1.1rem; }
  .code pre:focus-visible { outline:2px solid var(--accent); outline-offset:-2px; }
  ul { margin:0 0 1rem; padding-left:1.2rem; max-width:74ch; } li { margin:.25rem 0; }
  .edges { max-width:none; }
  .edges li { list-style:none; font-family:var(--mono); font-size:17px; margin:.45rem 0; }
  .edges li span { color:var(--muted); font-family:var(--serif); font-size:16px; }
  .tag { font:600 12.5px/1 var(--mono); letter-spacing:.08em; text-transform:uppercase; }
  .t-gone { color:var(--del); } .t-new { color:var(--add); } .t-flip { color:var(--accent); }
  diffs-container { display:block; margin:1.1rem 0 0; border:1px solid var(--rule);
                    border-radius:10px; --diffs-font-size:17px; --diffs-line-height:1.7;
                    --diffs-font-family:var(--mono); --diffs-header-font-family:var(--sans); }
  @media (max-width:1000px) { .ba { grid-template-columns:1fr; } body { font-size:17px; } }
</style>
</head>
<body>
<main>…</main>
<script type="module">
  const CDN = "https://esm.sh";
  const THEMES = { light: "github-light-high-contrast", dark: "github-dark-high-contrast" };
  const fail = (node, err) => {
    const pre = document.createElement("pre");
    pre.className = "render-error";
    pre.textContent = `Could not render: ${err.message}\n\n${node.textContent.trim()}`;
    node.replaceWith(pre);
  };
  const sources = (attr) => [...document.querySelectorAll(`script[${attr}]`)];

  const lightbox = document.createElement("dialog");
  lightbox.className = "lightbox";
  lightbox.addEventListener("click", () => lightbox.close());
  document.body.append(lightbox);

  const graphs = sources("data-mermaid");
  if (graphs.length) {
    try {
      const { renderMermaidSVG } = await import(`${CDN}/beautiful-mermaid@1.1.3`);
      for (const node of graphs) {
        try {
          const host = document.createElement("div");
          host.className = "diagram";
          host.innerHTML = renderMermaidSVG(node.textContent.trim(), {
            bg: "var(--diagram-bg)", fg: "var(--diagram-fg)", transparent: true,
          });
          const svg = host.firstElementChild;
          const vars = svg.getAttribute("style") || "";   // the --bg/--fg the theme rides on
          const w = Math.round(+svg.getAttribute("width"));   // fill the column, up to 1.8x
          svg.removeAttribute("width");
          svg.removeAttribute("height");
          svg.style.cssText = `${vars};width:100%;max-width:${Math.round(w * 1.8)}px;height:auto`;
          host.tabIndex = 0;
          host.role = "button";
          host.title = "Click to enlarge";
          const open = () => {
            const clone = svg.cloneNode(true);
            clone.style.cssText = vars;                   // let the lightbox size it
            lightbox.replaceChildren(clone);
            lightbox.showModal();
          };
          host.addEventListener("click", open);
          host.addEventListener("keydown", (e) => {
            if (e.key === "Enter" || e.key === " ") { e.preventDefault(); open(); }
          });
          node.replaceWith(host);
        } catch (err) { fail(node, err); }
      }
    } catch (err) { graphs.forEach((n) => fail(n, err)); }
  }

  const snippets = sources("data-code");
  if (snippets.length) {
    try {
      // Dual-theme tokens: every colour ships as light-dark(), so the block follows
      // color-scheme with no re-render and no second stylesheet.
      const { codeToHtml } = await import(`${CDN}/shiki@4.4.3`);
      const paint = (code, lang) =>
        codeToHtml(code, { lang, themes: THEMES, defaultColor: "light-dark()" });
      for (const node of snippets) {
        try {
          const code = node.textContent.trim();
          const host = document.createElement("div");
          host.className = `code ${node.dataset.side || ""}`.trim();
          host.innerHTML = await paint(code, node.dataset.code || "ts")
            .catch(() => paint(code, "txt"));           // unknown grammar stays readable
          node.replaceWith(host);
        } catch (err) { fail(node, err); }
      }
    } catch (err) { snippets.forEach((n) => fail(n, err)); }
  }

  const patches = sources("data-diff");
  if (patches.length) {
    try {
      const { FileDiff, getSingularPatch } = await import(`${CDN}/@pierre/diffs@1.3.6`);
      const wide = matchMedia("(min-width: 1000px)").matches;
      // The theme owns the token colours inside the shadow root, so the surface and the
      // add/del hues have to be forced back to the page palette from in there.
      const surface = `:host{
        --diffs-light-bg:#fff !important;         --diffs-dark-bg:#262223 !important;
        --diffs-light-addition-color:#5f6f00 !important; --diffs-dark-addition-color:#a8b833 !important;
        --diffs-light-deletion-color:#c22e2b !important; --diffs-dark-deletion-color:#f28a88 !important;
        --diffs-bg-addition-override:light-dark(#f5f6f0,#404026) !important;
        --diffs-bg-deletion-override:light-dark(#fbf2f2,#4f3737) !important;
      }`;
      for (const node of patches) {
        try {
          const patch = node.textContent.trim();
          const host = document.createElement("diffs-container");
          node.replaceWith(host);
          new FileDiff({
            diffStyle: node.dataset.diff === "unified" || !wide ? "unified" : "split",
            themeType: "system",
            theme: { light: THEMES.light, dark: THEMES.dark },
            unsafeCSS: surface,
            lineDiffType: "word",
            stickyHeader: true,
          }).render({ fileDiff: getSingularPatch(patch), fileContainer: host });
        } catch (err) { fail(node, err); }
      }
    } catch (err) { patches.forEach((n) => fail(n, err)); }
  }
</script>
</body>
</html>
```

Paste the loader as it is. It is the whole runtime. Put it once, at the end of the body.

Do not shrink the type and do not re-cap `main`. If a diagram still looks small, give it the
full row. Turn the `.ba` pair into one full-width card with before above after. Do not
reduce anything else.

## Embedding sources

There are three block types. All three are `<script type="text/plain">`, so the browser
never parses what is inside them. That makes `<`, `&`, and generics safe.

**Diagram.** The loader replaces the block with a themed SVG stretched to its column.

```html
<script type="text/plain" data-mermaid>
flowchart LR
  cli[cli.ts] --> core[core/]
  classDef new fill:var(--add-fill),stroke:var(--add),stroke-width:1.5px
  class core new
</script>
```

**Code.** For signatures, config, and any snippet you picked by hand. Shiki highlights it.
`data-code` is the language. `data-side` is optional and tints the border only.

```html
<div><span class="label was">Before</span>
<script type="text/plain" data-code="ts" data-side="was">
export function parse(input: string, store: Store): Promise<Order[]>
</script></div>
```

**Diff.** One file's patch per block, straight from `git diff`.

```html
<script type="text/plain" data-diff>
diff --git a/src/cli.ts b/src/cli.ts
@@ -1,4 +1,3 @@
-import { openStore } from "./store.ts";
+import { ingest } from "./core/mod.ts";
</script>
```

`data-diff="unified"` forces one column. The default is split on wide viewports and unified
on narrow ones.

Only one sequence ends a block early: a literal `</script` inside the source.

## Sections

Only two things are fixed. The header comes first. The picture that carries the change
comes second. Order the rest by what this change actually did, strongest evidence first.

The sections below are a menu, not a checklist. Pick the ones the change earns, drop the
rest, merge two when they say the same thing, and add one the list does not have when the
change needs it.

- **Header.** Subject line, the range described such as `abc123..def456`, a branch, or a
  PR number, the date, and a one-sentence headline. The headline is the structural change
  in plain words. No legend and no key. Green, red, and blue read themselves. Anything
  that would need explaining belongs in the card label or the node text.
- **The change in one picture.** Usually the before and after module graph pair. Sometimes
  the sequence pair or the seam is the better opener. Whichever it is, it goes second. A
  reader who stops here already has the answer.
- **What moved.** A short table with module, before role, after role, and verdict such as
  `new`, `absorbed`, `split`, or `unchanged`. Six rows at most. Group the rest.
- **Dependencies.** The edges that appeared, vanished, or reversed. One line each, `a → b`
  in monospace, with a reason of five words, tagged in the matching colour. Reversed edges
  go first.
- **Seams.** For each seam the change touched: what is on either side, what is
  substitutable across it, and whether it widened or narrowed.
- **Signatures.** Before and after pairs for exported functions and types whose shape
  changed. Two columns of `data-code` blocks, one `data-side="was"` and one
  `data-side="now"`, each under its own `.label` span. Signatures only, never whole
  bodies.
- **Key code changes.** Three to six rendered patches. Each gets a heading that says why
  it matters, not what the file is called. Not every changed file, only the ones that
  carry the architectural point.
- **Consequences.** Bullets of 8 words or fewer. What is now easier, what is now
  constrained, and what still has to happen. This section is allowed to be opinionated.

Two rules keep the freedom honest:

- **Never manufacture a section.** No seam moved means no seam section. An empty section is
  worse than a missing one.
- **Lead with the strongest fact.** If the headline is a reversed edge, dependencies come
  before the table. If it is a collapsed call chain, the sequence pair is the picture and
  the module graph may not be worth drawing at all.

A change that touches one module and no seams is a header, one diagram pair, and two
diffs. That is a finished report, not a thin one.

## Diagram patterns

Vary them. A page of five identical flowcharts reads as generated.

**Dependency graph, the workhorse.** Use `flowchart LR` for both sides. Keep the same node
names and the same direction on each side, so the eye can diff them. Colour every delta.

```
flowchart LR
  cli[cli.ts] --> core[core/]
  core --> store[(store.ts)]
  classDef new fill:var(--add-fill),stroke:var(--add),stroke-width:1.5px
  classDef gone fill:var(--del-fill),stroke:var(--del),stroke-width:1.5px
  class core new
  linkStyle 0 stroke:var(--add),stroke-width:1.5px
```

`linkStyle` indexes edges by declaration order, counting from 0. `classDef` supports `fill`,
`stroke`, `stroke-width`, and `color`. `linkStyle` supports `stroke` and `stroke-width`.
This renderer ignores `stroke-dasharray` on a node, so use a dotted edge (`-.->`) instead.

**Sequence diagram** when the point is round-trips or ordering. Before has six arrows.
After has one. Messages cannot be coloured one by one, so put the count in the card label,
such as `Before: 5 store round-trips`, and let the shape carry it.

**Seam diagram.** Two stacks either side of a dashed vertical rule, with the swappable
implementations listed under the port. Hand-build this with divs and one `<svg><line>`.
Mermaid fights you here and the result looks parachuted in.

**Cross-section bands.** Stacked horizontal divs for a call passing through layers. Before
has five thin bands, each doing little. After has one thick band.

Rules for all of them:

- No ASCII art anywhere.
- A before and after pair sits side by side without either card scrolling.
- Label nodes with real module paths.
- A diagram that needs a paragraph to be understood is wrong. Redraw it. A big diagram
  beats a small diagram plus an explanation.

## Voice

Write for an engineer who does not know this codebase and is not yet senior. Be plain,
specific, and unhedged.

- **No em dashes and no semicolons in prose.** Use a full stop, a comma, a colon, or a
  bullet. Code keeps its own punctuation.
- **One fact per sentence.** Split a two-clause sentence into two.
- **Simple words.** "uses", not "leverages". "so", not "consequently".
- **Bullets over paragraphs.** Three facts in a row become a list or a table. A paragraph
  runs to three sentences at most.
- **Consistent terms.** Module, edge, seam, node, hunk, patch, before side, after side. Use
  the repo's own glossary for the repo's own concepts.
- **Name real things.** Real files, real functions, real edges.

Good:

- "`orders/` no longer imports `pricing/`. Both now depend on `contracts/`."
- "The HTTP client moved behind the repository port. Tests drop the fake server."
- "One seam replaced three ad-hoc injection points."

Bad: "improved separation of concerns", "cleaner architecture", "better maintainability".
If a sentence would survive being pasted into a different report, it is too vague to keep.

## Style rules

- Prose is support. Diagrams, tables, and diffs carry the page. A section of three
  paragraphs is wrong.
- **All code is highlighted.** Snippets go through `data-code` and patches through
  `data-diff`. A hand-written `<pre>` of code in one flat colour is a bug. The only
  exception is the fallback for a patch containing `</script`.
- Colour means change. Green is added, red is removed, blue is moved or reversed. Nothing
  else earns colour, and nothing that changed is left grey.
- was/now on a code block lives in the border and the label. Never recolour the code text.
- No legend. The picture explains itself through conventional colours, real module paths as
  node labels, and a card label that names what you are looking at, such as
  `Before: 5 round-trips`. A diagram that needs a key is wrong.
- Never hardcode a hex inside a diagram. Use the `var(--add)`, `var(--del)`, and
  `var(--accent)` tokens, so both themes work.
- No decorative emoji. A ✓ or ✕ that carries meaning is fine.
- Every hand-written `<pre>` needs `white-space: pre` or `pre-wrap`, or newlines collapse.
  Rendered code and diffs handle their own whitespace.
- No coloured `border-left` accent stripes. That pattern reads as AI-generated. Use a small
  uppercase mono tag, a full border, or a background tint.
- Wide things such as tables, diffs, and long paths scroll inside their own container. The
  body never scrolls horizontally.
- Add no scripts of your own beyond the loader. One exception is allowed: a theme toggle
  that flips a `data-theme` attribute over the same tokens. It must also set `color-scheme`
  on the root, because highlighted code resolves `light-dark()` from it.

## Before handing it over

Open the file and look at it. The renderers run in the browser, so an unopened page is an
unverified page.

- Every diagram drew, with the nodes and edges you wrote. No block fell back to raw text.
- Every changed node and edge is coloured. Green added, red removed, blue moved. It reads
  without a key. Recount `linkStyle` indices against the arrows on screen.
- Diagrams fill their cards. Labels are comfortably readable at arm's length. Each diagram
  opens in the lightbox on click, still themed, and closes on click or Escape.
- Every `data-code` block is multi-coloured. A block in one flat colour means Shiki failed
  or the language was wrong.
- Every diff rendered. Split diffs are not cramped. Force `unified` if they are.
- Both themes checked. Diagram fills readable in dark, code readable in light.
- `python3 contrast.py <report>.html` prints "AA clean". `check-diff-contrast.js` in the
  console returns `failing: []` in light **and** dark. Never ship a failing pair.
- Every diagram shows a difference. Identical before and after pairs are deleted.
- No em dash and no semicolon in the prose. No paragraph over three sentences.
- No horizontal scrollbar on the body.
