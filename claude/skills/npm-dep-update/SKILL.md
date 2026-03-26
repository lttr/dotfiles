---
name: npm-dep-update
description: Analyze outdated npm/pnpm dependencies and provide upgrade guidance based on release notes.
allowed-tools: Bash, Read, Write, WebFetch, WebSearch
---

# Dependency Update Assessment

Analyze outdated npm/pnpm dependencies, fetch release notes, and produce actionable upgrade guidance.

## Workflow

Output a brief message explaining *why* before each step (not what - the user sees tool output).

1. Output: "Checking for outdated dependencies and fetching release notes (this queries npm and GitHub, may take a moment)..."

```bash
node "$CLAUDE_SKILL_DIR/scripts/find-release-notes.js"
```

Save the output to a file for reference (follow project conventions for artifact storage if any are in context).

2. Output: "Identifying breaking changes and upgrade risks..."
   Read the generated file to understand which dependencies need updates.

3. Based on the release notes content, provide:
   - **Breaking changes** - packages with major updates and what changed
   - **New features** - packages with minor updates worth noting
   - **Upgrade order** - dependencies that others rely on first
   - **Migration steps** - specific actions for packages with breaking changes
   - **Safe batch updates** - packages that can be updated together

4. If release notes are incomplete for packages with significant version jumps:
   Output: "Release notes missing for [package] - checking upstream..."
   Use WebFetch to consult the actual release notes URLs from the generated file.

5. End with a **Suggested upgrade commands** section:
   - Group safe batch updates: `vp update pkg1 pkg2 pkg3`
   - Individual commands for breaking changes: `vp update pkg@version`
   - Post-upgrade verification: `vp run typecheck`, `vp run test`, etc.
   - Format as a numbered list the user can execute sequentially.

Skip packages with only patch updates unless they contain security fixes.
Focus on actionable guidance. Be concise.
