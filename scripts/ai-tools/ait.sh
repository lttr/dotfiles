#!/usr/bin/env bash

# AI Translate - translate between Czech and English
claude --model haiku --print "Translate the input. If the input is in Czech, translate to English. If the input is in English, translate to Czech. If there are multiple valid translations, list all of them. When helpful, include a short example usage for each translation. Be concise. <input>$*</input>" | glow
