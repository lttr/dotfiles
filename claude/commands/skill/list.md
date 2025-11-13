---
allowed-tools: Bash
description: List all available Claude Code skills
---

## Context

Show all available Claude Code skills from both project-level and global directories.

## Your task

Use this single bash command to quickly list all skills:

```bash
# Function to extract description from frontmatter
extract_desc() {
    grep "^description:" "$1" 2>/dev/null | sed 's/^description: *//' | tr -d '"'
}

# Function to extract name from frontmatter
extract_name() {
    grep "^name:" "$1" 2>/dev/null | sed 's/^name: *//' | tr -d '"'
}

# List project skills if they exist
if [[ -d ".claude/skills" ]]; then
    echo "Project Skills:"
    for d in .claude/skills/*/; do
        if [[ -f "${d}SKILL.md" ]]; then
            name=$(extract_name "${d}SKILL.md")
            desc=$(extract_desc "${d}SKILL.md")
            # Fallback to directory name if no name in frontmatter
            [[ -z "$name" ]] && name=$(basename "$d")
            # Fallback to first heading if no description
            [[ -z "$desc" ]] && desc=$(grep -m 1 "^# " "${d}SKILL.md" 2>/dev/null | sed 's/^# //')
            [[ -z "$desc" ]] && desc="No description available"
            printf "\033[1m%s\033[0m - %s\n" "$name" "$desc"
        fi
    done
    echo
fi

# List global skills
echo "Global Skills:"
for d in ~/.claude/skills/*/; do
    if [[ -f "${d}SKILL.md" ]]; then
        name=$(extract_name "${d}SKILL.md")
        desc=$(extract_desc "${d}SKILL.md")
        # Fallback to directory name if no name in frontmatter
        [[ -z "$name" ]] && name=$(basename "$d")
        # Fallback to first heading if no description
        [[ -z "$desc" ]] && desc=$(grep -m 1 "^# " "${d}SKILL.md" 2>/dev/null | sed 's/^# //')
        [[ -z "$desc" ]] && desc="No description available"
        printf "\033[1m%s\033[0m - %s\n" "$name" "$desc"
    fi
done
```
