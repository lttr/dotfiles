---
allowed-tools: Bash(browser-start:*), Bash(browser-nav:*), Bash(browser-pick:*), Bash(browser-eval:*), Bash(nr:*), Bash(pnpm:*), Bash(npm:*), Bash(lsof:*), Bash(curl:*), Bash(ps:*), Read, Glob
description: Pick an element from the browser (starts dev server if needed)
argument-hint: [prompt]
---

## Context

- Current working directory: !`pwd`
- Package.json dev script (if exists): !`cat package.json 2>/dev/null | grep -E '"dev":|"start":' | head -2 || echo "No dev/start script"`
- Check for running dev server: !`lsof -i :3000 -i :5173 -i :4000 -i :8080 2>/dev/null | grep LISTEN | head -3 || echo "No dev server detected on common ports"`
- Check if Chrome is running with debugging: !`lsof -i :9222 2>/dev/null | grep LISTEN || echo "Chrome not running on :9222"`

## Your task

Help user pick an element from the browser. Follow these steps:

**Step 1: Ensure Chrome is running**
- If Chrome is not running on port 9222, start it with `browser-start --profile`

**Step 2: Check for dev server**
- If a dev server is already running (detected on ports 3000, 5173, 4000, or 8080), note the URL
- If NO dev server is running AND package.json has a `dev` or `start` script:
  - Start the dev server in background: `nr dev` (or `nr start`)
  - Wait a few seconds for it to start
  - Navigate to the appropriate localhost URL

**Step 3: Navigate if needed**
- If Chrome is on a blank page or not on localhost, navigate to the dev server URL
- Use `browser-eval 'window.location.href'` to check current URL if unsure

**Step 4: Run element picker**
- Run `browser-pick` with the user's prompt (if provided): `browser-pick "$ARGUMENTS"`
- If no prompt provided, use: `browser-pick "Select an element"`

**Step 5: Return results**
- Show the selected element details (tag, id, classes, text content)
- Provide a CSS selector that can be used to target the element

## User prompt (if any)

$ARGUMENTS
