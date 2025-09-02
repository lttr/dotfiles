#!/bin/bash

# Find all AGENTS.md files in current directory and subdirectories
# This is a temporary solution for case that Claude Code not satisfies with AGENTS.md usage case. 
# https://docs.anthropic.com/en/docs/claude-code/hooks#project-specific-hook-scripts
find "$CLAUDE_PROJECT_DIR" -name "AGENTS.md" -type f | while read -r file; do
    echo "--- File: $file ---"
    cat "$file"
    echo ""
done
