---
allowed-tools: Bash(npm:*), Bash(pnpm:*), Bash(nr:*), Bash(ni:*), Bash(test:*), Bash(ls:*), Bash(find:*), Bash(cat:*), Read
description: Verify project and fix errors automatically
argument-hint:
---

## Context

- Working directory: !`pwd`
- package.json: !`ls package.json 2>/dev/null || echo "not found"`
- Scripts: !`cat package.json 2>/dev/null | grep -A 30 '"scripts"' || echo "none"`

## Task

Verify project, report and fix errors.

**1. Detect setup**
- Package manager: `pnpm` (or `npm` if package-lock.json exists)
- If `verify` script exists → run it and stop

**2. Run scripts in phases**

| Phase | Scripts | Execution |
|-------|---------|-----------|
| 1 | lint, typecheck | Parallel (two Bash calls, one message) |
| 2 | test | After phase 1 |
| 3 | build | After phase 2 |

- Skip missing scripts
- Continue to next phase on failures (collect all errors)

**3. Non-JS projects**
- Use locally installed tools only
- Don't install dependencies

**4. Error handling**
- Fix simple errors (formatting, unused imports)
- For complex/many errors: report them, suggest fix plan, don't attempt bulk fixes

**5. Summary**
- Status: ✅ passed | ⚠️ warnings | ❌ failures
- Remaining issues needing attention
