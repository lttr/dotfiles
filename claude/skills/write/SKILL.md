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

Plain words by default. Use an established domain term when the domain (or a project glossary) already uses it; don't invent a plainer synonym for a term everyone knows.

Overplain:

> The editor merges changes from several people without a central server deciding the order.

Right:

> The editor merges concurrent edits with CRDTs, so no central server decides the order.

## 5. Structure for scanning

A note is scanned before it is read. Give each idea a visible anchor: a **bold lead-in phrase**, a bullet in a parallel list, a heading in a long note. Compact notation earns its place when the reader gets it faster than from a sentence: arrow ladders (`ad hoc → written → enforced`), parentheticals for asides and rejected alternatives.

Never strip structure that is already doing its job. When rewriting, keep or sharpen the original's anchors; dissolving a list into paragraphs is a downgrade. The only guard: a bare list with no connecting claim makes the reader reconstruct the argument, so state the claim the list supports.

## 6. Short sentences, fragments allowed

Prefer two short sentences over one joined by an em-dash or semicolon. Inside structured lines (bullets, definitions, parentheticals), fragments are fine when the meaning survives.

## 7. Say it once

No repetition. No closing summary that restates the note. When the point is made, stop.

## 8. Evidence serves understanding

Paraphrase errors, paths, and reproduction steps to whatever precision the reader needs. Exact verbatim output is not required. Keep a detail exact only when the reader will act on it (a command to run, a config key to change).
