#!/usr/bin/env bash
# Hook to reset session timer when /clear is issued
# This creates a marker file with the current timestamp that the status line script uses

# Read JSON from stdin
input=$(cat)

# Get session_id from input JSON
session_id=$(echo "$input" | jq -r '.session_id // empty')
[[ -z "$session_id" ]] && exit 0

# Get git directory
git_dir=$(git rev-parse --git-common-dir 2>/dev/null)
[[ -z "$git_dir" ]] && exit 0

# Create statusbar directory if needed
mkdir -p "$git_dir/statusbar"

# Write current timestamp in milliseconds to marker file
echo "$(date +%s)000" > "$git_dir/statusbar/session-${session_id}-clear-marker"
