---
name: tldr
description: Re-emit your own last answer tighter, following the project and global CLAUDE.md and output-style rules more strictly. Use when the user says "/tldr", "tldr", "tighten that", "too long", or "just the point".
disable-model-invocation: true
allowed-tools: Read
---

# TL;DR - distill the last answer

Rewrite **your immediately preceding response** as the leanest version that still says everything the user needs. Nothing more, nothing less.

## Rules

1. Re-read the active rules first and apply whichever the original broke: `~/.claude/CLAUDE.md`, the active output-style, and the nearest project `CLAUDE.md` from cwd upward.
2. Tighten hard:
   - Answer first, as a fragment. No build-up, no recap.
   - Bullets and fragments over prose. Five or fewer bullets means no section headers.
   - One bullet, one idea. Drop any sentence that loses nothing when removed.
   - Cut praise, fluff, "why this is better" closers, and aphorisms.
   - Tighter, not harder to read. Plain everyday words. Shorter must never mean cryptic.
   - No mdash and no semicolons. Use a period, a comma, or "and".
3. Keep all substance: diffs, commands, error output, file:line refs, and security or risk warnings stay verbatim. Concise applies to prose, not evidence.
4. Don't redo the work. This is a rewrite, not a new attempt. If the original was wrong, say so in one line instead of silently fixing it.

## Output

Just the tightened answer. No preface, no list of what you cut, no follow-up questions. If the last answer was already minimal, say so in one line and stop.
