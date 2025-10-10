---
allowed-tools: Bash
description: List all available Claude Code custom commands
---

## Context

Show all available Claude Code custom commands from both project-level and global directories.

## Your task

Use this single bash command to quickly list all commands:

```bash
# Function to extract description from frontmatter
extract_desc() {
    awk '/^---$/ { in_fm = (in_fm ? 0 : 1); next } in_fm && /^description:/ { gsub(/^description: */, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit }' "$1" 2>/dev/null || echo ""
}

# List project commands if they exist
if [[ -d ".claude/commands" ]]; then
    echo "Project Commands:"
    for f in .claude/commands/*.md; do
        if [[ -f "$f" ]]; then
            name=$(basename "$f" .md)
            desc=$(extract_desc "$f")
            printf "/\033[1m%s\033[0m - %s\n" "$name" "$desc"
        fi
    done
    echo
fi

# List global commands
echo "Global Commands:"
for f in ~/.claude/commands/*.md; do
    if [[ -f "$f" ]]; then
        name=$(basename "$f" .md)
        desc=$(extract_desc "$f")
        printf "/\033[1m%s\033[0m - %s\n" "$name" "$desc"
    fi
done
```
