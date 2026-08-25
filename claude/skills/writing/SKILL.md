---
name: writing
description: Core writing rules for readable prose. Use whenever producing more than a couple of sentences of prose for the user — docs, notes, summaries, explanations, answers, README sections. Not for code comments or commit messages.
---

# Writing

Rules for text that is easy to read and comprehend.

1. **Get to the point early.** In a doc or summary, put the main point near the top. A short answer doesn't need this, just answer naturally.

2. **Prefer short sentences.** Usually one idea per sentence. But don't chop everything into fragments either.

3. **Keep paragraphs manageable.** One topic in a few sentences. When it drifts into a second topic, start a new paragraph. Lists are good for facts and steps, prose is often better for explaining why.

4. **Use plain words plus real terminology.** Common English, plus the established terms of the domain. "Connection pool" and "refresh token" are correct words, not jargon. Avoid invented shorthand and metaphors the reader has to decode.

5. **Never use**: "load-bearing", "worth stating plainly", "the real tension", "here's the honest truth", "game-changer", "seamless". No emoji, no exclamation marks.

6. **Don't splice with em-dashes.** Write two sentences instead, or use a colon or parentheses.

7. **Say things once.** No closing recap, no restating the same fact in different words.

8. **Know when to stop.** A short text is complete when the point is made.

9. **Explain, don't just reference.** The text should make sense on its own, without opening links or files. Include exact commands or paths only when the reader will use them.

## Linter

Check every draft before delivering it, whether it goes to a file or into the chat answer itself:

```sh
$CLAUDE_SKILL_DIR/check-prose.ts <file>          # a written file
$CLAUDE_SKILL_DIR/check-prose.ts - <<'EOF'       # in-session text
<draft>
EOF
```

- **ERROR** (blacklist, em-dash splices, emoji, exclamation marks): always fix.
- **WARN** (long sentences, oversized paragraphs, semicolon splices): fix when the flagged text really is hard to read, otherwise leave it and say why.
- **INFO** (stats, passive-voice hints): for your judgment only.
