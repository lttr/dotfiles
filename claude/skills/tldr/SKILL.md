---
name: tldr
description: Re-assess your own last answer and re-emit it tighter, obeying the project + global CLAUDE.md and output-style rules more strictly. Use when the user says "/tldr", "tldr", "tighten that", "too long", "just the point", or wants the previous response distilled to only what they need to read.
disable-model-invocation: true
allowed-tools: Read
---

# TL;DR - distill the last answer

Take **your own immediately preceding response** and re-emit it as the leanest version that still carries everything the user actually needs. Nothing more, nothing less.

## Rules to enforce

1. Re-read the active instructions before rewriting:
   - Global: `~/.claude/CLAUDE.md` and the active output-style (already in context, re-read if unsure).
   - Project: nearest `CLAUDE.md` from cwd upward.
   Apply whichever rules the original answer broke.
2. Apply the output-style hard:
   - Verdict/answer first, as a fragment. No build-up, no recap.
   - Bullets/fragments over prose. ≤5 bullets → no section headers.
   - One bullet, one idea. Delete-test every sentence. If removing it loses nothing, remove it.
   - Cut praise, fluff, "why this is better" closers, aphorisms.
   - Err shorter than feels natural.
   - Tighter, not harder to read. Use normal everyday words and plain sentences. Shorter must never mean more cryptic or telegraphic.
   - No mdash (—) and no semicolons. Use a period, a comma, or "and" instead.
3. **Never drop substance.** Keep full diffs, commands, error output, file:line refs, security caveats, and risk warnings verbatim. Concise applies to prose, not evidence.
4. Don't re-run work or re-investigate. This is a rewrite of what was already said, not a new attempt. If the original was wrong, say so in one line rather than silently fixing.

## Output

Just the tightened answer. Don't preface it ("Here's the shorter version..."), don't explain what you cut, don't ask follow-ups. Emit the distillation and stop.

If the last answer was already minimal, say so in one line and leave it.
