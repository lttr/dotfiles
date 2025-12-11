---
description: Analyze outdated dependencies and provide upgrade guidance based on release notes
allowed-tools: Bash, Read, Write, WebFetch, WebSearch
---

## Context

This command helps assess dependency updates in a JavaScript/TypeScript project. It runs `find-release-notes` to gather outdated npm dependencies and their release notes, then analyzes what's needed for successful upgrades.

## Your task

1. **Create logs directory if needed:**
   ```bash
   mkdir -p .aitools/logs
   ```

2. **Generate dependency release notes with timestamped filename:**
   ```bash
   TIMESTAMP=$(date +%Y-%m-%d)
   find-release-notes > ".aitools/logs/dependency-update-notes-${TIMESTAMP}.md"
   ```

3. **Read the generated file:**
   Read the generated `.aitools/logs/dependency-update-notes-${TIMESTAMP}.md` file to understand which dependencies need updates.

4. **Analyze and advise:**
   Based on the release notes content, provide:
   - Summary of packages with breaking changes (major updates)
   - Summary of packages with new features (minor updates)
   - Prioritized upgrade order (dependencies that others rely on first)
   - Specific migration steps for packages with breaking changes
   - Any packages that can be safely batch-updated together

5. **If release notes are incomplete:**
   Use WebFetch to consult the actual release notes URLs listed in the file for packages with significant version jumps.

Focus on actionable guidance. Skip packages with only patch updates unless they contain security fixes.
