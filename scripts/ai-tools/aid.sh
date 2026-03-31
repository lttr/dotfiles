#!/usr/bin/env bash

# AI Dictionary - explain a word or phrase concisely
ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY_FOR_TOOLS" claude --bare --model haiku --print "Explain the word like a dictionary, no more than 3 sentences or bullet points. Use the same language as the input is, english is the default. <input>$*</input>" | glow
