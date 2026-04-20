#!/bin/bash
# Log user-typed slash commands. Fires from UserPromptSubmit.
# Captures leading /name token(s) — skills loaded via <command-name>
# do NOT invoke the Skill tool, so this is the only way to log them.
# Format: ts\tsource\tsession_id\tcwd\tskill\targs
# Output: ~/.claude/custom-skill-usage.log

payload=$(cat)
prompt=$(jq -r '.prompt // ""' <<< "$payload")
session_id=$(jq -r '.session_id // ""' <<< "$payload")
cwd=$(jq -r '.cwd // ""' <<< "$payload")

# Match leading /<name> where name = word chars, colons, dashes.
# Trim leading whitespace first.
trimmed="${prompt#"${prompt%%[![:space:]]*}"}"
[[ "$trimmed" != /* ]] && exit 0

# Extract command and args.
first_line="${trimmed%%$'\n'*}"
head="${first_line%% *}"
cmd="${head#/}"
args="${first_line#"$head"}"
args="${args# }"
args="${args:0:60}"

# Skip empty / purely-path ("/home/...") prompts.
[[ -z "$cmd" || "$cmd" == */* ]] && exit 0

printf '%s\tslash\t%s\t%s\t%s\t%s\n' \
  "$(date -u +%s)" "$session_id" "$cwd" "$cmd" "$args" \
  >> ~/.claude/custom-skill-usage.log
