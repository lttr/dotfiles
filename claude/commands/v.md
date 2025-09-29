---
allowed-tools: Bash(npm:*), Bash(pnpm:*), Bash(nr:*), Bash(ni:*), Bash(test:*), Bash(ls:*), Bash(find:*), Bash(cat:*), Read
description: Verify project and fix errors automatically
argument-hint:
---

## Context

- Current working directory: !`pwd`
- Check if package.json exists: !`ls package.json 2>/dev/null || echo "No package.json found"`
- Package.json scripts (if exists): !`cat package.json 2>/dev/null | grep -A 20 '"scripts"' || echo "No scripts section found"`

## Your task

Verify the project and fix any errors that arise. Follow this priority order:

**Step 1: Detect project type**
- Check if `package.json` exists to determine if it's a JavaScript/TypeScript project
- Report project type found

**Step 2: Run verification scripts**
- If `package.json` has a `verify` script: run `pnpm run verify` (or `npm run verify` if package-lock.json exists)
- If no `verify` script exists, try these in order:
  1. `pnpm run lint` (if lint script exists)
  2. `pnpm run typecheck` (if typecheck script exists)
  3. `pnpm run test` (if test script exists)
  4. `pnpm run build` (if build script exists)

**Step 3: Handle other project types**
- For non-package.json projects, attempt to use locally installed tools only
- Try common verification commands if tools are available locally
- Do NOT install new tools or dependencies

**Step 4: Error handling**
- Report results of each script and whether it exists
- Fix simple, obvious errors (like missing semicolons, unused imports, etc.)
- **CRITICAL**: For complex errors with many issues, just report them - do not attempt to fix everything at once
- Provide a clear plan for fixing complex errors in iterations

**Step 5: Summary**
- Provide final status of verification
- List any remaining issues that need manual attention
- Suggest next steps for complex problems