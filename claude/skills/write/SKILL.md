---
name: write
description: Write or rewrite a concise note that explains a concept or issue for fast human understanding. Only when the user explicitly invokes it (/write). Not for specs, RFCs, ADRs, or incident writeups (use technical-writing), and not for code comments or commit messages.
---

# Write

Write a note a human reads once and gets. The reader is you in six months or a colleague catching up. Every rule serves one goal: fastest possible understanding.

## 1. Conclusion first

The first sentence states the point. Support afterward. No warm-up, no scene-setting.

Buried:

> The checkout service has been timing out intermittently since Tuesday. After looking at the logs and tracing several requests, it turned out the connection pool was exhausted.

First:

> Checkout timeouts since Tuesday come from an exhausted connection pool. Traced via request logs.

## 2. Length matches the topic

No fixed length. A two-line note is complete if the topic is small. A page is fine if the topic needs it. The cut rule: drop any sentence that doesn't change what the reader understands or does next.

When rewriting an existing text, the result must be meaningfully shorter or clearer than the original. If a pass produces neither, say so and keep the original instead of shuffling its words.

## 3. Self-contained

The note carries its own meaning. The reader should not need to open a link, the repo, or another doc to get the message. Don't paste whole docs in either. Summarize what matters; reference the rest.

## 4. Simple language, real terms

Readers may not be native English speakers. Use common English words. When a rare or idiomatic word has an everyday synonym, take the synonym: "rung" → "level", "dissolve" → "turn into", "earns its place" → "is worth using". Don't coin shorthand of your own ("pack users"); repeat the full phrase or restructure.

The one exception is established domain terms. When the domain (or a project glossary) already uses a term, use it; don't invent a plainer synonym for a term everyone knows.

Overplain:

> The editor merges changes from several people without a central server deciding the order.

Right:

> The editor merges concurrent edits with CRDTs, so no central server decides the order.

## 5. Structure for scanning

A note is scanned before it is read. Give each idea a visible anchor: a **bold lead-in phrase** followed by a colon, a bullet in a parallel list, a heading in a long note. Use compact notation when the reader gets it faster than from a sentence: arrow chains (`ad hoc → written → enforced`), parentheses for side remarks and rejected alternatives.

Never remove structure that already works. When rewriting, keep or sharpen the original's anchors; turning a list into paragraphs is a downgrade. The only guard: a bare list with no connecting claim makes the reader rebuild the argument, so state the claim the list supports.

## 6. Short sentences, fragments allowed

Prefer two short sentences over one joined by an em-dash or semicolon. Inside structured lines (bullets, definitions, parentheticals), fragments are fine when the meaning survives.

## 7. Say it once

No repetition. No closing summary that restates the note. When the point is made, stop.

## 8. Evidence serves understanding

Paraphrase errors, paths, and reproduction steps to whatever precision the reader needs. Exact verbatim output is not required. Keep a detail exact only when the reader will act on it (a command to run, a config key to change).

## 9. Final pass: grep the draft

Never deliver a draft unchecked. Write it to a file (scratchpad if the note has no target file), then run:

```sh
grep -nE '—|;' <draft-file>
```

Every hit is a defect, except semicolons inside code (fenced blocks or backticked spans). Fix by position:

- After a bold lead-in (`**Lead-in** — rest`): replace with a colon.
- Joining two clauses: split into two sentences.
- Introducing an aside: move the aside into parentheses.

Re-run until grep prints nothing (or only code-span semicolons remain). Only then deliver the note.
