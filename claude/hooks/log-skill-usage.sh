#!/bin/bash
# Log every Skill tool invocation with timestamp, user, skill name, and args
# Output: ~/.claude/skill-usage.log

payload=$(cat)
skill=$(jq -r '.tool_input.skill' <<< "$payload")
args=$(jq -r '.tool_input.args // ""' <<< "$payload")

echo "$(date -u +%s)  $USER  $skill  $args" >> ~/.claude/skill-usage.log
