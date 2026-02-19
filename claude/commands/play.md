---
allowed-tools: Bash(playwright-cli:*), Bash(npx playwright-cli:*), Bash(nr:*), Bash(pnpm:*), Bash(npm:*), Bash(lsof:*), Bash(curl:*), Bash(ps:*), Read, Glob, Grep
description: Open browser and test functionality with Playwright
argument-hint: [what to test or URL]
---

## Context

- Working directory: !`pwd`
- Dev scripts: !`cat package.json 2>/dev/null | grep -E '"dev"|"start"|"preview"' | head -3 || echo "No dev/start script"`
- Running dev server: !`lsof -i :3000 -i :5173 -i :4000 -i :8080 -i :4173 2>/dev/null | grep LISTEN | head -3 || echo "No dev server on common ports"`
- Git recent changes: !`git diff --name-only HEAD~1 2>/dev/null | head -10 || echo "no git history"`

## Task

Load the `playwright-cli` skill and use Playwright to test in a real browser.

**If $ARGUMENTS is empty:** infer what to test from recent git changes or conversation context. Look at recently modified files to understand what was just implemented.

**If $ARGUMENTS is a URL:** navigate directly to it and explore/test.

**If $ARGUMENTS is a description:** use it as instructions for what to test.

### Steps

1. **Start browser** - `playwright-cli open --headed` (or `playwright-cli open --headed <url>` if URL given). Only omit `--headed` if $ARGUMENTS contains the word "headless".
2. **Start dev server if needed** - If testing localhost and no server running, start one in background with `nr dev` or `nr start`
3. **Navigate** to the relevant page
4. **Test the functionality** - Interact with the UI: click buttons, fill forms, navigate flows. Use `playwright-cli snapshot` to read page state and find element refs.
5. **Verify** - Check that the feature works: look for expected text, elements, state changes, console errors (`playwright-cli console`), network requests (`playwright-cli network`)
6. **Report** - Summarize what you tested, what passed, and any issues found

### Guidelines

- Take snapshots frequently to understand page state
- Check the browser console for errors after interactions
- If something looks wrong, take a screenshot with `playwright-cli screenshot`
- Test both happy path and obvious edge cases
- Be thorough but focused - test the specific feature, not the entire app

## Instructions

$ARGUMENTS
