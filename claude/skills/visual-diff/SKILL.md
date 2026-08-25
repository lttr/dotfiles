---
name: visual-diff
description: Visual before/after walkthrough of a code change as a standalone HTML file with colour-coded module diagrams, seams, and key diffs.
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

# Visual Diff

Produce **one self-contained HTML file** that shows how a change reshaped the code:

- what the modules were and what they are now
- which dependencies appeared or vanished
- where the seams moved
- which interfaces changed

This is an **architecture** report, not a line-by-line diff tour. The reader should come
away knowing how the shape of the code changed, not what every hunk does.

Two rules make the page readable. Neither is negotiable.

- **Every difference is colour-coded.** Green means added. Red means removed. Indigo means
  moved or reversed. The palette is the Solarized-ish one from lukastrumm.com. A node or
  edge that changed but is drawn in the default grey is a bug. There is no legend, because
  the picture explains itself.
- **The diagrams are the page.** They get the full width. The text scales with them.
  Nothing is squeezed into a narrow column.

## Words to use

These terms carry the report. Use them in the same sense on every page.

- **Module** is a real unit of code, not a file. A directory of five files behind one
  export is one module.
- **Edge** is a dependency from one module to another. It is an import or a call.
- **Seam** is an interface you can substitute across. A repository port and its fake are
  one seam.
- **Node** is a box in a diagram. It usually stands for a module.
- **Hunk** is one `@@` block inside a patch. **Patch** is the output of `git diff` for one
  file.
- **Before side** and **after side** are the two states of the code. Say "before" and
  "after", not "old" and "new".

## 1. Resolve the target

Work out what change to describe from the argument and the repo state.

- No argument, so use the uncommitted working tree (`git status`, `git diff HEAD`). Clean
  tree falls back to the branch diff.
- Branch or "this branch", so use `git diff $(git merge-base <base> <branch>)..<branch>`.
  Find the base with `git symbolic-ref refs/remotes/origin/HEAD`, else `main` or `master`.
- PR number or URL, so use `gh pr diff <n>` and `gh pr view <n>`.
- Commit or range, so use `git diff <range>`. Staged only means `git diff --cached`.
- "the changes you just made", so use whatever this session touched. That is usually the
  working tree.

State the reading you picked and move on. Never ask when one reading is obviously right.

## 2. Reconstruct both architectures

You need the **before** state, not just the diff. Check out nothing. Read it out of git.

```bash
git diff --stat <range>                     # what moved
git diff --name-status <range>              # A/M/D/R, renames are architecture signal
git show <base>:path/to/file.ts             # the file as it was
```

Then work out both sides:

- **Modules.** Find the real units. Ignore the file count.
- **Edges.** Grep the import statements on each side and diff the two sets. This is the
  backbone of the report, so do it properly instead of from memory.
- **Seams.** Name the interfaces the change moved, widened, narrowed, or introduced. Say
  what is substitutable across each one, such as real impl against test fake, or HTTP
  against in-process.
- **Public signatures.** Find exported functions and types whose shape changed. Get the
  exact before and after text.
- **Direction of change.** List deleted edges, new edges, and edges that flipped. A
  reversed edge is the single most reportable fact in the whole document.

Track one label for every node and edge you will draw: **before only**, **after only**, or
**both**. That label is what you colour in step 4. Collect it now instead of guessing at
drawing time.

Do not invent structure the code does not have. If a change is local and moves no seam, say
so plainly. Do not dress it up as architecture.

## 3. Choose what earns a diagram

Budget one before/after pair for the module graph, plus a handful of focused pairs at most.

A diagram must show a **difference**. If the before and after render the same, cut the pair
and write one sentence instead.

Good candidates, best first:

1. Module dependency graph, before against after.
2. Call or data flow through the changed path. A sequence diagram is great for "6
   round-trips becomes 1".
3. The seam, showing what plugs in on each side.
4. Signature changes. These need no diagram. A two-column code block is clearer.

## 4. Colour the change

Every diagram uses the same three colours. They are CSS variables, so they follow the page
theme. Paste this palette at the bottom of each flowchart or state diagram and tag the
nodes.

```
  classDef gone fill:var(--del-fill),stroke:var(--del),stroke-width:1.5px
  classDef new fill:var(--add-fill),stroke:var(--add),stroke-width:1.5px
  classDef moved fill:var(--accent-fill),stroke:var(--accent),stroke-width:1.5px
```

- On the **before** diagram, tag `gone` on everything the change deletes.
- On the **after** diagram, tag `new` on everything the change introduces.
- Tag `moved` on either side when a node survives but changes role, moves module, or sits
  at either end of a reversed edge.
- Leave everything untouched untagged, so it stays default grey. The contrast is the whole
  point.

Edges take the same colours through `linkStyle`. It indexes edges by declaration order,
counting from 0, top to bottom, across the whole diagram.

```
  linkStyle 0,1 stroke:var(--del),stroke-width:1.5px
  linkStyle 2 stroke:var(--add),stroke-width:1.5px
```

A wrong index silently colours the wrong arrow. Recount against the source after you write
it, then check it in the browser.

Two renderer limits are worth knowing, because `beautiful-mermaid` is not upstream mermaid.

- `classDef` honours `fill`, `stroke`, `stroke-width`, and `color`. It **ignores**
  `stroke-dasharray`. A dashed node border is not available. Carry "provisional" or
  "substitutable" in the edge (`-.->`) or in the label instead.
- `linkStyle` honours `stroke` and `stroke-width` only.

Both accept `var(--token)` as written. It lands in the SVG unresolved, so one diagram
recolours itself in light and dark. Never hardcode a hex in a diagram.

Sequence diagrams cannot colour a single message. Show the change with the shape, such as
five arrows becoming one. Put the colour in the card label above it.

## 5. Write the page

There is no build step. You embed the **sources** and a small loader turns them into
diagrams, highlighted code, and interactive diffs at view time. The loader pulls two ESM
modules from a CDN.

Three block types cover everything:

```html
<script type="text/plain" data-mermaid>
flowchart LR
  cli[cli.ts] --> core[core/]
</script>

<script type="text/plain" data-code="ts" data-side="now">
export function parse(input: string): Order[]
</script>

<script type="text/plain" data-diff>
diff --git a/src/cli.ts b/src/cli.ts
@@ -1,4 +1,3 @@
...
</script>
```

So the pipeline for a diff is short. Run `git diff <range> -- <file>`, then paste the
output between the tags.

- `data-code` holds hand-picked code such as a signature. Shiki highlights it token by
  token. Set the language in the attribute, for example `data-code="ts"`. Set
  `data-side="was"` or `data-side="now"` to tint the border red or green.
- `data-diff` holds a raw patch. `@pierre/diffs` renders it with Shiki highlighting,
  word-level marks inside a line, selectable lines, and a sticky file header. Add
  `data-diff="unified"` to force one column. The default is split on wide viewports and
  unified on narrow ones.
- `data-mermaid` holds diagram text. `beautiful-mermaid` renders it.

**No code on the page is ever a single flat colour.** Every snippet and every patch goes
through one of these two highlighters. Never hand-write a `<pre>` full of code and colour
it red or green. The was/now signal lives in the border and the label, not in the text.

Two things to get right when pasting:

- Keep each block to one file's diff. Split a multi-file `git diff` into one block per file.
- The only sequence that breaks a block is a literal `</script` inside the patch, because
  the HTML parser ends the script there. It shows up when you diff HTML. Rewriting it would
  falsify the patch. Put that one diff in a plain `<pre>` and leave the rest live.

Then assemble the page following **[HTML-REPORT.md](./HTML-REPORT.md)**. Read it before you
write any HTML. It has the scaffold, the loader to paste as is, the section menu, the theme
tokens, and the diagram patterns. **[example.html](./example.html)** is a finished report
built this way. Open it to see the target.

## 6. Language

The page is read by an engineer who does not know this codebase. Write for them.

- **No em dashes and no semicolons in prose.** Use a full stop, a comma, a colon, or a
  bullet. Code and CSS keep their own punctuation.
- **Short sentences.** One fact each. If a sentence has two clauses, split it.
- **Simple words.** Say "uses", not "leverages". Say "so", not "consequently". Assume the
  reader is competent but not senior.
- **Bullets over paragraphs.** Three or more facts in a row become a list or a table.
  A paragraph is at most three sentences.
- **Domain terms from the list above**, used consistently. Where the repo has its own
  glossary or docs, prefer its words for its own concepts.
- **Name real things.** Real files, real functions, real edges.
- **No hedging.** Drop "arguably", "essentially", "it seems".

Good:

- "`orders/` no longer imports `pricing/`. Both now depend on `contracts/`."
- "The HTTP client moved behind the repository port. Tests drop the fake server."
- "One seam replaced three ad-hoc injection points."

Bad: "improved separation of concerns", "cleaner architecture", "better maintainability".
If a sentence would survive being pasted into a different report, it is too vague to keep.

## 7. Deliver

- Save outside the repo, with a date prefix:
  `/tmp/$(date +%Y-%m-%d)-visual-diff-<slug>.html`
- Open it: `setsid xdg-open <file> >/dev/null 2>&1 &`
- Tell the user the path and the one-line headline of what changed structurally.

## Notes

- The page loads three modules from `esm.sh` on open, so the first viewer needs network.
  Warm load is fast. A cold CDN build takes a few seconds. Everything else, meaning layout,
  prose, and tables, renders without them. A failed import degrades to the raw source in a
  bordered block instead of a blank space.
- The page is fluid, not a fixed column. Diagrams and diffs use the whole viewport. Only
  prose is capped at a readable measure. Do not reintroduce a narrow `max-width` on `main`.
- Diagram text scales with the diagram, because the SVG is upscaled to its container. That
  is why a wide page is a legible page. Leave the upscaling in the loader alone.
- `beautiful-mermaid` covers flowchart, state, sequence, class, ER, and XY charts. It
  quietly ignores syntax it does not know. After opening the page, check that each diagram
  has the nodes, the edges, **and** the colours you wrote.
- Diagrams read `--diagram-bg`, `--diagram-fg`, and the change tokens as live CSS
  variables. They restyle with the page theme without re-rendering. Define every one of
  them in light and dark.
- The shipped tokens are WCAG AA in both themes, for the page and for rendered code alike.
  Contrast beats prettiness. If you touch a colour, run `python3 contrast.py <report>.html`
  for the page palette, and paste `check-diff-contrast.js` into the console for the syntax
  colours inside diffs and code blocks. Both files live next to HTML-REPORT.md.
- Clicking any diagram opens it full width in a lightbox. The loader wires that up, so a
  dense graph stays readable even when its card is half a row.
