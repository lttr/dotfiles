#!/bin/bash

# Load the project root AGENTS.md file (if present).
# This is a temporary solution for case that Claude Code not satisfies with AGENTS.md usage case.
# https://docs.anthropic.com/en/docs/claude-code/hooks#project-specific-hook-scripts
file="$CLAUDE_PROJECT_DIR/AGENTS.md"
if [ -f "$file" ]; then
    echo "--- File: $file ---"
    cat "$file"
    echo ""
fi
