#!/usr/bin/env bash

# AI Dictionary - explain a word or phrase concisely
claude --model haiku --print "Explain the word like a dictionary, no more than 3 sentences or bullet points. Use the same language as the input is, english is the default. <input>$*</input>" | glow
