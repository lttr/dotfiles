#!/bin/bash
# Log Skill tool invocations. Fires from PreToolUse matcher=Skill.
# Format: ts\tsource\tsession_id\tcwd\tskill\targs
# Output: ~/.claude/custom-skill-usage.log

payload=$(cat)
skill=$(jq -r '.tool_input.skill // ""' <<< "$payload")
args=$(jq -r '.tool_input.args // ""' <<< "$payload")
session_id=$(jq -r '.session_id // ""' <<< "$payload")
cwd=$(jq -r '.cwd // ""' <<< "$payload")

[ -z "$skill" ] && exit 0

# Truncate args — not used for analysis, just a sanity hint.
args="${args:0:60}"
args="${args//[$'\t\n\r']/ }"

printf '%s\ttool\t%s\t%s\t%s\t%s\n' \
  "$(date -u +%s)" "$session_id" "$cwd" "$skill" "$args" \
  >> ~/.claude/custom-skill-usage.log
