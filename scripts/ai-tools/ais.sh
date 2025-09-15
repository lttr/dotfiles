#!/usr/bin/env bash

# Search the web using Claude and return top 3 results
input="$*"
prompt="
You are a web search expert. Search the web for the given query and return the 3 most relevant results. Format your response as a description on one line (max 80 characters) followed by the URL. Use this exact format:

<example_output>
Short description here
URL

Short description here
URL

Short description here
URL
</example_output>

Never output markdown, additional text, or explanations. Only output the 3 formatted result lines.
"

# Get Claude's response with web search enabled (using faster model)
response=$(claude --allowedTools "WebSearch" --model claude-3-haiku-20240307 -p "$prompt Search query: $input")

# Add blank line at the beginning
echo ""

# Output the response directly since it should already be formatted correctly
echo "$response"
