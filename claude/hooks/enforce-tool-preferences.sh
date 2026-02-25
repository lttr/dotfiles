#!/usr/bin/env bash
#
# Claude Code PreToolUse hook: enforce tool preferences
# Blocks commands using non-preferred tools and suggests alternatives.
#
# Exit 0 = allow, Exit 2 = block (stderr fed back to Claude)
#
# Rules:
#   find → fd
#   grep/egrep → rg (or Grep tool)
#   npm <subcommand> → pnpm (unless package-lock.json exists)
#   npx → px

set -euo pipefail

LOG_FILE="${HOME}/.claude/cache/hook-blocks.log"

# Read JSON from stdin
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

[[ -z "$command" ]] && exit 0

# Strip leading whitespace and env vars for matching
# We match against the raw command to catch pipes too
block() {
  local rule="$1" suggestion="$2"
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] BLOCKED rule=$rule cmd=${command:0:120}" >> "$LOG_FILE"
  echo "Blocked by tool-preference hook: $suggestion" >&2
  exit 2
}

# --- Rule 1: find → fd ---
# Match "find" as a standalone command (start of line, after pipe, after &&/||/;)
if echo "$command" | grep -qP '(?:^|[|;&]\s*)find\s+'; then
  block "find→fd" "Use 'fd' instead of 'find'. Example: fd -e ts (finds all .ts files)"
fi

# --- Rule 2: grep/egrep → rg ---
# Match grep/egrep as standalone commands
if echo "$command" | grep -qP '(?:^|[|;&]\s*)e?grep\s+'; then
  block "grep→rg" "Use 'rg' instead of 'grep/egrep', or use the built-in Grep tool. Example: rg 'pattern' or rg -l 'pattern'"
fi

# --- Rule 3: npm → pnpm ---
# Only block npm subcommands that have pnpm equivalents, and only when no package-lock.json
if echo "$command" | grep -qP '(?:^|[|;&]\s*)npm\s+(install|i|run|exec|init|create|test|start|ci)\b'; then
  if [[ ! -f "package-lock.json" ]]; then
    # Extract the npm subcommand for a better suggestion
    sub=$(echo "$command" | grep -oP '(?:^|[|;&]\s*)npm\s+\K(install|i|run|exec|init|create|test|start|ci)')
    case "$sub" in
      run)
        # Extract script name: npm run build → pnpm build
        script=$(echo "$command" | grep -oP 'npm\s+run\s+\K\S+' || true)
        block "npm→pnpm" "Use 'pnpm ${script:-<script>}' instead of 'npm run ${script:-<script>}' (or 'nr ${script:-<script>}')"
        ;;
      install|i)
        block "npm→pnpm" "Use 'pnpm install' (or 'ni') instead of 'npm install'"
        ;;
      exec)
        block "npm→pnpm" "Use 'px' instead of 'npm exec'"
        ;;
      *)
        block "npm→pnpm" "Use 'pnpm $sub' instead of 'npm $sub'"
        ;;
    esac
  fi
fi

# --- Rule 4: npx → px ---
if echo "$command" | grep -qP '(?:^|[|;&]\s*)npx\s+'; then
  # Extract the package name for a better suggestion
  pkg=$(echo "$command" | grep -oP '(?:^|[|;&]\s*)npx\s+\K\S+' || true)
  block "npx→px" "Use 'px ${pkg:-<package>}' instead of 'npx ${pkg:-<package>}' (px tries pnpm exec, falls back to pnpm dlx)"
fi

exit 0
