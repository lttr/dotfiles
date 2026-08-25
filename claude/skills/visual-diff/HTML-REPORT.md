# HTML Report Format

The walkthrough is a single HTML file. It embeds the **sources**, meaning Mermaid text,
hand-picked code, and raw git patches. The loader at the end of the body renders them in
the browser: diagrams to SVG, snippets and patches to highlighted code. Which renderer does
what is pinned in the scaffold, so you never have to pick one.

No bundler and nothing pre-rendered. Edit the body, rebuild, reload. The page needs network
on open. If an import fails, each block falls back to its raw source in a bordered `<pre>`,
so an offline reader still sees the patch.

The palette and type are set in the scaffold:

- warm off-white or charcoal ground
- green, red, and indigo for the change colours
- a geometric sans for headings over a serif body
- a fixed-width face for code

Keep those tokens as they are. Every pair in them was measured readable in both themes, so
shipping them is the reason you do not have to think about colour at all.

Highlighted code carries a second, separate palette. Patches render inside a shadow root,
so the loader forces the surface, the add and del hues, and the row tints back to the page
tokens through `unsafeCSS`. Those hexes are a hand-synced mirror of the `:root` tokens. If
you retune a colour, change both, and keep `--code-bg` equal to `--diffs-light-bg` and
`--diffs-dark-bg`. Then look at the page in both themes. This is a report, not a production
site, so your eyes are the check.

Three layout rules hold the whole format together.

- **The page is fluid.** `main` fills the viewport up to a generous cap. Only prose is
  capped at a readable measure. A diagram pair on a 27" display gets two columns of roughly
  800px.
- **One vertical rhythm.** Every rendered block, meaning a `.ba` pair, a `.card`, a
  `.code`, a `pre`, a table, and a diff, carries the same `--flow` margin underneath and
  nothing above. That margin collapses with the next heading's larger one, so sections
  never drift. Add no margins of your own, and never put a spacer div between blocks.
- **Diagrams upscale.** The loader stretches each SVG to its container, up to 1.8 times its
  intrinsic size. The text inside scales with it. Wide page, big diagrams, and big labels
  are the same decision. Clicking one opens it in a lightbox at up to 94vw, which is the
  escape hatch for a dense graph.

## Scaffold

You never write the head, the palette, or the loader. Write only the body, meaning
everything from `<main>` to `</main>`, then wrap it:

```bash
SKILL_DIR=<absolute path of this skill directory>
node "$SKILL_DIR/build.mjs" body.html --title "Visual diff: <subject>" --open
```

`SKILL_DIR` is where this file lives, so use that absolute path rather than a hardcoded
home directory. Add `--out <file>` to pick the destination. Without it the page goes to the
OS temp directory under today's date. The build prints the path either way.

`scaffold.html` supplies the rest and is the single source of truth. Do not copy it into
your report by hand and do not edit it for one report. Rerunning the build picks up any
scaffold fix for free.

[example.html](./example.html) is a finished report built exactly this way, from
[example-body.html](./example-body.html). Read that body to see the target. Regenerate it
with the same command if you ever change the scaffold.

The layout is not yours to shrink. Do not re-cap `main` and do not reduce the type. If a
diagram still looks small, give it the full row: turn the `.ba` pair into one full-width
card with before above after.

The class vocabulary the scaffold gives you:

| Class | Use |
|---|---|
| `.lede` | the one-sentence headline under `h1` |
| `.meta` | the range, branch, or PR number, and the date |
| `.ba` | two-column before/after grid, collapses under 1000px |
| `.card` | a bordered well, usually one side of a `.ba` |
| `.label`, `.label.was`, `.label.now` | small uppercase mono caption above a card or code block |
| `.edges` | list of `a → b` dependency lines, each path pair wrapped in `<code>` |
| `.tag`, `.t-gone`, `.t-new`, `.t-flip` | inline uppercase tag in the change colours |
| `.caption` | a note that belongs to the block above it, so it hugs instead of floating |
| `.diagram`, `.code`, `diffs-container` | built by the loader, never hand-written |

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

**Code.** For signatures, config, and any snippet you picked by hand. The loader highlights
it. `data-code` is the language. `data-side` is optional and tints the border only.

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

Only one sequence ends a block early: a literal `</script` inside the source. It shows up
when you diff HTML. Rewriting it would falsify the patch, so put that one diff in a plain
`<pre>` and leave the rest live.

## Sections

Only two things are fixed. The header comes first. The picture that carries the change
comes second. Order the rest by what this change actually did, strongest evidence first.

The sections below are a menu, not a checklist. Pick the ones the change earns, drop the
rest, merge two when they say the same thing, and add one the list does not have when the
change needs it. An empty section is worse than a missing one, so never manufacture one.

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
  in monospace, with a reason of a few words, tagged in the matching colour. Reversed edges
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
- **Consequences.** One short bullet each. What is now easier, what is now constrained,
  and what still has to happen. This section is allowed to be opinionated.

**Lead with the strongest fact.** If the headline is a reversed edge, dependencies come
before the table. If it is a collapsed call chain, the sequence pair is the picture and the
module graph may not be worth drawing at all.

A change that touches one module and no seams is a header, one diagram pair, and two
diffs. That is a finished report, not a thin one.

## Diagram patterns

Vary them. A page of five identical flowcharts reads as generated.

**Dependency graph, the usual choice.** Use `flowchart LR` for both sides. Keep the same node
names and the same direction on each side, so the eye can diff them. Colour every delta.

```
flowchart LR
  cli[cli.ts] --> core[core/]
  core --> store[(store.ts)]
  classDef gone fill:var(--del-fill),stroke:var(--del),stroke-width:1.5px
  classDef new fill:var(--add-fill),stroke:var(--add),stroke-width:1.5px
  classDef moved fill:var(--accent-fill),stroke:var(--accent),stroke-width:1.5px
  class core new
  linkStyle 0 stroke:var(--add),stroke-width:1.5px
```

`linkStyle` indexes edges by declaration order, counting from 0, top to bottom, across the
whole diagram. A wrong index silently colours the wrong arrow, so recount against the
source after you write it.

This renderer is not upstream mermaid. `classDef` honours `fill`, `stroke`, `stroke-width`,
and `color`. `linkStyle` honours `stroke` and `stroke-width`. Neither honours
`stroke-dasharray`, so carry "provisional" or "substitutable" in a dotted edge (`-.->`) or
in the label. Both accept `var(--token)` as written, and it lands in the SVG unresolved, so
one diagram recolours itself in light and dark.

**Sequence diagram** when the point is round-trips or ordering. Before has six arrows.
After has one. Messages cannot be coloured one by one, so put the count in the card label,
such as `Before: 5 store round-trips`, and let the shape carry it.

**Hand-built shapes.** When Mermaid fights the picture, build it from divs and one inline
`<svg><line>` rather than forcing it. A seam reads well as two stacks either side of a
dashed vertical rule, with the swappable implementations listed under the port. A call
passing through layers reads well as stacked horizontal bands, five thin ones before and
one thick one after.

Rules for all of them:

- No ASCII art anywhere.
- A before and after pair sits side by side without either card scrolling.
- Label nodes with real module paths.
- A diagram that needs a paragraph to be understood is wrong. Redraw it. A big diagram
  beats a small diagram plus an explanation.

## Style rules

Prose follows **§6 Language in SKILL.md**. Read it before writing any.

- Prose is support. Diagrams, tables, and diffs carry the page. A section of three
  paragraphs is wrong.
- **All code is highlighted.** Snippets go through `data-code` and patches through
  `data-diff`. A hand-written `<pre>` of code in one flat colour is a bug. The only
  exception is the `</script` fallback above.
- Colour means change. Green is added, red is removed, blue is moved or reversed. Nothing
  else earns colour, and nothing that changed is left grey.
- was/now on a code block lives in the border and the label. Never recolour the code text.
- No legend. The picture explains itself through conventional colours, real module paths as
  node labels, and a card label that names what you are looking at, such as
  `Before: 5 round-trips`. A diagram that needs a key is wrong.
- Never hardcode a hex inside a diagram. Use the `var(--add)`, `var(--del)`, and
  `var(--accent)` tokens, so both themes work.
- Every file, module, function, and edge name sits in `<code>`, in prose, tables, and edge
  comments alike. The scaffold renders inline code as a bordered chip.
- No decorative emoji. A ✓ or ✕ that carries meaning is fine.
- No coloured `border-left` accent stripes. That pattern reads as AI-generated. Use a small
  uppercase mono tag, a full border, or a background tint.
- Wide things such as tables, diffs, and long paths scroll inside their own container. The
  body never scrolls horizontally.
- Add no scripts of your own beyond the loader.

## Before handing it over

One look is enough. Open the page and check for three problems:

- A block fell back to raw text (`pre.render-error`), or a diagram is missing nodes.
- Something that changed is still grey, or a `linkStyle` coloured the wrong arrow.
- A `data-code` block is one flat colour, meaning the language was wrong or the
  highlighter failed.

Fix anything you find, then deliver the page.
