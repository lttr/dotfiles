#!/usr/bin/env bash

# List repo-specific Claude Code config: skills, slash commands, hooks, and MCP
# servers. Like `deps`, but for a project's .claude setup. Usage: clls [path]

shopt -s nullglob globstar
root="${1:-.}"

section() { printf '\n\e[1m%s\e[0m\n' "$1"; }            # bold header
desc() { rg -m1 -N '^description:' "$1" | cut -c14-; }    # frontmatter description
trunc() { (( ${#1} > 70 )) && printf '%.70s...' "$1" || printf '%s' "$1"; }

# --- Skills: name, description ---
skills=("$root"/.claude/skills/*/SKILL.md)
if (( ${#skills[@]} )); then
  section SKILLS
  for md in "${skills[@]}"; do
    printf '  %-20s %s\n' "$(basename "$(dirname "$md")")" "$(trunc "$(desc "$md")")"
  done
fi

# --- Slash commands: namespaced name (subdir -> name:sub), description ---
cmds=("$root"/.claude/commands/**/*.md)
if (( ${#cmds[@]} )); then
  section COMMANDS
  for md in "${cmds[@]}"; do
    name=${md#*/commands/}; name=${name%.md}; name=${name//\//:}
    printf '  /%-20s %s\n' "$name" "$(trunc "$(desc "$md")")"
  done
fi

# --- Hooks: event, matcher, command (from settings*.json) ---
hooks=$(jq -r '(.hooks // {}) | to_entries[] | .key as $e | .value[] |
  "  \($e)  \(.matcher // "*")  \(.hooks[].command)"' \
  "$root"/.claude/settings.json "$root"/.claude/settings.local.json 2>/dev/null)
[[ -n $hooks ]] && { section HOOKS; printf '%s\n' "$hooks"; }

# --- MCP servers: name, command or url (from .mcp.json) ---
mcp=$(jq -r '(.mcpServers // {}) | to_entries[] |
  "  \(.key)  \(.value.command // .value.url // "")"' "$root"/.mcp.json 2>/dev/null)
[[ -n $mcp ]] && { section MCP; printf '%s\n' "$mcp"; }
