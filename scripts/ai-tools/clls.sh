#!/usr/bin/env bash

# Glance at how Claude Code behaves in a project: memory files, project/local
# plugins, settings, permissions, skills, agents, commands, hooks, and MCP
# servers. Like `deps`, but for a project's .claude setup. Usage: clls [path]

shopt -s nullglob globstar
root="${1:-.}"
proj="$root/.claude/settings.json"
lcl="$root/.claude/settings.local.json"

section() { printf '\n\e[1m%s\e[0m\n' "$1"; }            # bold header
desc() { rg -m1 -N '^description:' "$1" | cut -c14-; }    # frontmatter description
trunc() { (( ${#1} > 70 )) && printf '%.70s...' "$1" || printf '%s' "$1"; }
cols=$(tput cols 2>/dev/null || echo 120)
fit() { while IFS= read -r l; do (( ${#l} > cols )) && echo "${l:0:cols-3}..." || echo "$l"; done; }

# Run a jq filter over each existing settings file, prefixing lines with scope.
per_scope() {
  local f scope
  for scope in project local; do
    f=$proj; [[ $scope == local ]] && f=$lcl
    [[ -f $f ]] && jq -r --arg s "$scope" "$1" "$f"
  done
}

# --- Memory: CLAUDE.md files loaded for this folder (nested ones load lazily) ---
mem=()
for f in "$root"/{CLAUDE.md,CLAUDE.local.md,.claude/CLAUDE.md} "$root"/.claude/rules/**/*.md; do
  [[ -f $f ]] || continue
  mem+=("  ${f#"$root"/}  ($(wc -l <"$f") lines)")
done
nested=$(fd -H -t f '^CLAUDE(\.local)?\.md$' "$root" --min-depth 2 -E .claude -E node_modules 2>/dev/null | wc -l)
(( nested )) && mem+=("  + $nested nested CLAUDE.md")
(( ${#mem[@]} )) && { section MEMORY; printf '%s\n' "${mem[@]}"; }

# --- Plugins: enabledPlugins from project and local settings (false = disabled) ---
plugins=$(per_scope '(.enabledPlugins // {}) | to_entries[] |
  "  \($s|.+"     "|.[:8])\(.key)\(if .value == false then "  \u001b[2m(disabled)\u001b[0m" else "" end)"')
[[ -n $plugins ]] && { section PLUGINS; printf '%s\n' "$plugins"; }

# --- Settings: remaining top-level keys; env shows names only (may hold secrets) ---
settings=$(per_scope 'del(.hooks, .enabledPlugins, .permissions, .extraKnownMarketplaces) |
  to_entries[] | "  \($s|.+"     "|.[:8])\(.key) = " +
  (if .key == "env" then (.value | keys | join(", ")) else (.value | tojson) end)')
[[ -n $settings ]] && { section SETTINGS; printf '%s\n' "$settings" | fit; }

# --- Permissions: allow on one line (often long), deny/ask/dirs one per line ---
perms=$(per_scope '(.permissions // {}) | to_entries[] | select(.value | length > 0) |
  "  \($s|.+"     "|.[:8])\(.key) (\(.value | length))" as $h |
  if (.value | type) != "array" then "\($h): \(.value)"
  elif .key == "allow" then "\($h): \(.value | join("  "))"
  else $h, (.value[] | "            \(.)") end')
[[ -n $perms ]] && { section PERMISSIONS; printf '%s\n' "$perms" | fit; }

# --- Skills / agents / output styles: name, description ---
list_md() { # header, name-mode (dir|file), files...
  local header=$1 mode=$2; shift 2
  (( $# )) || return
  section "$header"
  for md; do
    [[ $mode == dir ]] && n=$(basename "$(dirname "$md")") || n=$(basename "$md" .md)
    printf '  %-20s %s\n' "$n" "$(trunc "$(desc "$md")")"
  done
}
list_md SKILLS dir "$root"/.claude/skills/*/SKILL.md
list_md AGENTS file "$root"/.claude/agents/*.md
list_md "OUTPUT STYLES" file "$root"/.claude/output-styles/*.md

# --- Slash commands: namespaced name (subdir -> name:sub), description ---
cmds=("$root"/.claude/commands/**/*.md)
if (( ${#cmds[@]} )); then
  section COMMANDS
  for md in "${cmds[@]}"; do
    name=${md#*/commands/}; name=${name%.md}; name=${name//\//:}
    printf '  /%-20s %s\n' "$name" "$(trunc "$(desc "$md")")"
  done
fi

# --- Hooks: event, matcher, command ---
hooks=$(per_scope '(.hooks // {}) | to_entries[] | .key as $e | .value[] |
  "  \($s|.+"     "|.[:8])\($e)  \(.matcher // "*")  \(.hooks[].command)"')
[[ -n $hooks ]] && { section HOOKS; printf '%s\n' "$hooks"; }

# --- MCP servers: name, command or url (from .mcp.json) ---
mcp=$(jq -r '(.mcpServers // {}) | to_entries[] |
  "  \(.key)  \(.value.command // .value.url // "")"' "$root"/.mcp.json 2>/dev/null)
[[ -n $mcp ]] && { section MCP; printf '%s\n' "$mcp"; }
