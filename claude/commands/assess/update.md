---
description: Analyze outdated dependencies and provide upgrade guidance based on release notes
allowed-tools: Bash, Read, Write, WebFetch, WebSearch
---

## Context

This command helps assess dependency updates in a JavaScript/TypeScript project. It runs `find-release-notes` to gather outdated npm dependencies and their release notes, then analyzes what's needed for successful upgrades.

## Your task

Output a brief message explaining *why* before each step (not what - the user sees tool output).

1. Output: "Checking for outdated dependencies and fetching their release notes (this may take a moment as it queries npm and GitHub)..."
   ```bash
   mkdir -p .aiwork/logs
   TIMESTAMP=$(date +%Y-%m-%d)
   find-release-notes > ".aiwork/logs/dependency-update-notes-${TIMESTAMP}.md"
   ```

2. Output: "Identifying breaking changes and upgrade risks..."
   Read the generated file to understand which dependencies need updates.

3. Based on the release notes content, provide:
   - Summary of packages with breaking changes (major updates)
   - Summary of packages with new features (minor updates)
   - Prioritized upgrade order (dependencies that others rely on first)
   - Specific migration steps for packages with breaking changes
   - Any packages that can be safely batch-updated together

4. If release notes are incomplete for packages with significant version jumps:
   Output: "Release notes missing for [package] - checking upstream..."
   Use WebFetch to consult the actual release notes URLs.

Focus on actionable guidance. Skip packages with only patch updates unless they contain security fixes.

5. End with a "Suggested upgrade commands" section containing copy-pasteable commands:
   - Group safe batch updates: `pnpm update pkg1 pkg2 pkg3`
   - Individual commands for breaking changes: `pnpm update pkg@version`
   - Any post-upgrade verification steps: `nr typecheck`, `nr test`, etc.

   Format as a numbered list the user can execute sequentially or ask Claude to run.
