---
name: explain-diff-html
description: Produce a rich, interactive HTML explanation of a code change — diff, working tree, branch, or PR. Use when the user says "/explain-diff-html", "explain this diff", "explain this change", "explain this PR/branch".
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob
---

# Explain Diff

Make a rich, interactive explanation of the specified code change.

## Resolve the target

Figure out what change to explain from the argument (if any) and the repo state:

- No argument: explain the uncommitted working-tree changes (`git status`, `git diff HEAD`). If the working tree is clean, fall back to the diff of the current branch vs its base (see below).
- A branch name, or "this branch" / "the feature branch": diff the branch against its merge base with the default branch — `git diff $(git merge-base <base> <branch>)..<branch>`. Find the base branch with `git symbolic-ref refs/remotes/origin/HEAD` or fall back to `main`/`master`.
- A PR number/URL, or "this PR": use `gh pr diff <n>` (and `gh pr view <n>` for context).
- A commit / range / ref (e.g. `abc123`, `HEAD~3..HEAD`): `git diff <range>`.
- Staged only: `git diff --cached`.

When ambiguous, state which interpretation you picked and proceed. Read the actual diff, then broadly explore the surrounding code before writing.

## Scope to the size of the change

Default to a concise, proportionate explanation — the artifact should not dwarf the diff it explains. For a small or focused change, lead with **Intuition + Code** and drop the deep background and the quiz. Add Background and Quiz only for a large or genuinely unfamiliar change, or when the user asks. If unsure, start lean; it's easy to expand on request.

## Sections

- **Intuition** (always): Explain the core intuition for the code change. Focus on the essence, not the full details. Use concrete examples with toy data. Lead with figures and diagrams, not prose.
- **Code** (always): A high-level walkthrough of the changes. Group/order the changes in an understandable way. Prefer a compact visual layout (e.g. per-file cards with a one-liner + a tiny snippet) over long prose blocks.
- **Background** (only for large/unfamiliar changes, or on request): Explain the existing system relevant to this change. Broadly explore surrounding code. Include a deep background for beginners (skippable if familiar), then a narrower background directly relevant to the change.
- **Quiz** (only for large changes, or on request): Five medium-difficulty questions — hard enough to require understanding the substance, but not gotchas. Interactive multiple-choice: on click, say whether correct and give feedback.

## Format

- Output a single self-contained HTML file with inline CSS and JavaScript. One page with section headers; add a table of contents only if the page is long enough to warrant one. Don't use tabs for the top-level structure. Basic responsive styling for phone viewing is nice.
- Support the viewer's light/dark theme (`prefers-color-scheme` plus a manual toggle) via CSS variables.
- Save the file outside the code repo, filename starting with today's date in `YYYY-MM-DD-` format (keeps files time-sorted and out of version control). Example: `/tmp/2026-01-12-explanation-<slug>.html`. Get today's date with `date +%Y-%m-%d`.
- Write with the clarity and flow of Martin Kleppmann — engaging, classic style, smooth transitions between sections. But be **visual-first**: prefer diagrams, annotated mockups, and compact cards over paragraphs; keep prose tight.
- Diagrams: pick a small number of diagram families and reuse them throughout. Useful kinds:
  - A very simplified version of the app UI, to explain UI changes.
  - A system diagram showing data flow or communication between components — include example data.
- Don't use ASCII diagrams. Always use simple HTML designs for diagrams, HTML lists for lists, etc.

### Visual style (avoid the "AI-generated" look)

- Use emoji sparingly or not at all. A functional symbol (a ✓/✕ pass-fail mark) is fine; decorative emoji sprinkled into headings, node titles, and callouts are not.
- Don't differentiate elements with a colored `border-left` accent stripe — it reads as AI-generated. Distinguish categories another way: a small uppercase mono text tag in the category color, a subtle full-background tint, or a full (all-sides) border.
- For code blocks, always use `<pre>` tags. If you use a custom styled div instead, it **must** have `white-space: pre-wrap` in its CSS, or the browser collapses all newlines into one line. Before saving, scan each code block in the HTML source and confirm its CSS includes `white-space: pre` or `pre-wrap`.
- Use callouts for key concepts or definitions, important edge cases, etc.

After saving, open it in the default browser automatically — `setsid xdg-open <file> >/dev/null 2>&1 &` — then tell the user the file path.
