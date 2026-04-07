#!/usr/bin/env bash

# AI Translate - translate between Czech and English
ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_FOR_TOOLS" claude --bare --model haiku --print "Translate the input between Czech and English. Auto-detect the source language.

Format:
- Start with: **word** (Source Language → Target Language)
- Number each translation, most common first
- Add a brief label in parentheses after each translation
- Show one example phrase for each: • \"example\" (translation)
- End with a short note on the most common usage

Be concise. No extra commentary.

<input>$*</input>" | glow
