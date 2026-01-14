---
description: Add or remove Claude attribution from project settings
argument-hint: [enable|disable] [local|team]
---

## Context

Claude Code can add attribution to commits and PRs. This setting is controlled via:
- **Project local:** `.claude/settings.local.json` (gitignored, personal preference)
- **Project team:** `.claude/settings.json` (shared with team)

The attribution object structure:
```json
{
  "attribution": {
    "commit": "",
    "pr": ""
  }
}
```

When set to empty strings, attribution is disabled. When not present or set to default values, attribution is enabled.

## Your task

Parse the arguments from `$ARGUMENTS` to determine:
1. **Action:** `enable` or `disable` (required)
2. **Scope:** `local` (default) or `team`

### If arguments are missing or unclear:
Ask the user:
1. "Enable or disable attribution?"
2. "Apply to local settings (gitignored) or team settings (shared)?"

### Steps:

1. **Determine target file:**
   - `local` → `.claude/settings.local.json`
   - `team` → `.claude/settings.json`

2. **Read existing settings** (if file exists)

3. **Update attribution:**
   - **disable:** Set `attribution: { commit: "", pr: "" }`
   - **enable:** Remove the `attribution` key entirely (uses defaults)

4. **Write the file** with proper JSON formatting

5. **Report result:**
   ```
   Attribution [enabled|disabled] in [local|team] settings.
   File: <path>
   ```

### Examples:

```
/attribution disable local
→ Disables attribution in .claude/settings.local.json

/attribution enable team
→ Enables attribution in .claude/settings.json

/attribution disable
→ Disables attribution in .claude/settings.local.json (default)
```
