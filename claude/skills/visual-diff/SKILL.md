---
name: visual-diff
description: Visual before/after walkthrough of a change (working tree, branch, PR, or range) as a standalone HTML file with colour-coded module diagrams, seams, and key diffs.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
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
  moved or reversed. The palette ships in the scaffold. A node or edge that changed but is
  drawn in the default grey is a bug. There is no legend, because the picture explains
  itself.
- **The diagrams are the page.** They get the full width. The text scales with them.
  Nothing is squeezed into a narrow column.

## Words to use

- **Module** is a real unit of code, not a file. A directory of five files behind one
  export is one module.
- **Edge** is a dependency from one module to another. It is an import or a call.
- **Seam** is an interface you can substitute across. A repository port and its fake are
  one seam.
- Say **before** and **after**, never "old" and "new".

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
and write one sentence instead. Signature changes need no diagram at all, because a
two-column code block is clearer.

Good candidates, best first:

1. Module dependency graph, before against after.
2. Call or data flow through the changed path. A sequence diagram is great for "6
   round-trips becomes 1".
3. The seam, showing what plugs in on each side.

The renderer covers flowchart, state, sequence, class, ER, and XY charts. It quietly
ignores syntax it does not know, so stay inside that set.

## 4. Colour the change

Every diagram uses the same three colours, as CSS variables, so they follow the page theme.

- On the **before** diagram, tag `gone` on everything the change deletes.
- On the **after** diagram, tag `new` on everything the change introduces.
- Tag `moved` on either side when a node survives but changes role, moves module, or sits
  at either end of a reversed edge.
- Leave everything untouched untagged, so it stays default grey. The contrast is the whole
  point.

Sequence diagrams cannot colour a single message. Show the change with the shape, such as
five arrows becoming one. Put the colour in the card label above it.

HTML-REPORT.md carries the `classDef` and `linkStyle` syntax and the renderer's limits.
Two rules matter enough to state here: never hardcode a hex in a diagram, and recount your
`linkStyle` indices against the arrows on screen, because a wrong index silently colours
the wrong one.

## 5. Write the page

You embed the **sources**, meaning Mermaid text, hand-picked code, and raw git patches.
Nothing is pre-rendered: a loader turns them into diagrams, highlighted code, and
interactive diffs when the page opens. Three block types cover everything: `data-mermaid`,
`data-code`, and `data-diff`, all on `<script type="text/plain">`.

**No code on the page is ever a single flat colour.** Every snippet and every patch goes
through one of the two highlighters. Never hand-write a `<pre>` full of code and colour it
red or green. The was/now signal lives in the border and the label, not in the text.

Keep each block to one file's diff. Split a multi-file `git diff` into one block per file.

You write the **body only**, meaning everything from `<main>` to `</main>`. A build script
wraps it in the scaffold that carries the head, the palette, and the loader, so none of that
is ever yours to copy or retype.

Follow **[HTML-REPORT.md](./HTML-REPORT.md)** and read it before you write any HTML. It has
the build command, the exact markup, the section menu, and the diagram patterns.
**[example-body.html](./example-body.html)** is a finished body built this way.

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

- Write the body to a scratch file, then build and open it. `SKILL_DIR` is the directory
  this SKILL.md was loaded from, so set it to that absolute path instead of typing a home
  directory:
  ```bash
  SKILL_DIR=<absolute path of this skill directory>
  node "$SKILL_DIR/build.mjs" body.html --title "Visual diff: <subject>" --open
  ```
- The build prints the path it wrote. Without `--out` that is the OS temp directory, named
  with today's date, so the report never lands in the repo. `--open` uses the right opener
  for the platform.
- Tell the user the printed path and the one-line headline of what changed structurally.

One verification pass is enough. Do not re-read the file you just wrote, and do not walk a
checklist item by item. HTML-REPORT.md lists the three failures worth a look.

The page needs network on first open, because the loader pulls its renderers from a CDN.
Warm load is fast. A cold build takes a few seconds. Layout, prose, and tables render
without them, and a failed import degrades to the raw source in a bordered block instead of
a blank space.
