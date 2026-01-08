---
allowed-tools: Bash(git:*), Read, Glob, Grep, Task
description: Review code changes in current feature branch
argument-hint: [base-branch]
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Default branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "master"`

## Task

Perform a thorough code review of changes in the current feature branch. Follow these steps precisely:

### Step 1: Pre-flight checks

1. **Uncommitted changes warning**: If `git status --short` shows any output, warn: "⚠ Uncommitted changes detected. Consider committing or stashing before review."
2. **Determine base branch**: Use `$ARGUMENTS` if provided, otherwise detect default branch (check `refs/remotes/origin/HEAD`, fallback to `master`)
3. **Verify we're not on default branch**: If current branch equals base branch, abort with: "Already on default branch. Switch to a feature branch to review."

### Step 2: Gather context

1. **Find CLAUDE.md files**: Locate root CLAUDE.md and any CLAUDE.md in directories containing modified files
2. **Get change summary**: Run `git diff <base>...HEAD --stat` for overview
3. **List modified files**: Run `git diff <base>...HEAD --name-only`

### Step 3: Launch 5 parallel review agents (use Task tool with Sonnet)

Each agent reviews independently and returns issues with file paths, line numbers, and reasoning:

**Agent #1 - CLAUDE.md Compliance**
- Audit changes against all found CLAUDE.md guidelines
- Quote specific violated guidelines
- Skip guidelines that don't apply during code review

**Agent #2 - Bug Detection**
- Focus ONLY on changed code (use `git diff <base>...HEAD`)
- Identify actual bugs, logic errors, edge cases
- Ignore stylistic issues, nitpicks, pre-existing problems
- Skip likely false positives

**Agent #3 - Git History Context**
- Run `git log <base>...HEAD --oneline` to understand commit history
- Use `git blame` on modified sections to understand context
- Identify issues that contradict recent intentional changes

**Agent #4 - Security & Error Handling**
- Check for security issues (injection, XSS, auth bypass, secrets)
- Verify error handling in new code paths
- Check input validation at system boundaries

**Agent #5 - Code Comments & Intent**
- Verify changes comply with existing inline comments
- Check if TODO/FIXME comments need addressing
- Ensure code matches documented intent

### Step 4: Confidence scoring

For each issue found, use a Haiku agent to score confidence (0-100):

- **0**: False positive; doesn't hold up to scrutiny
- **25**: Might be real, but unverified; stylistic issues not in CLAUDE.md
- **50**: Verified as real but nitpicky; minor importance
- **75**: Highly confident; real issue affecting functionality or violates CLAUDE.md
- **100**: Absolutely certain; direct evidence of bug or security issue

### Step 5: Filter and report

1. Keep only issues with confidence **≥80**
2. If no issues meet threshold, report: "No significant issues found. Checked for bugs, security, and CLAUDE.md compliance."
3. Otherwise, output in this format:

```
## Code Review: <branch-name>

Reviewed <N> files, <M> commits against <base-branch>

### Issues Found

1. **[Category]** file/path.ts:42-48
   Description of the issue
   Confidence: 85

2. **[Bug]** src/utils.ts:123
   Description with specific code reference
   Confidence: 92

### Summary
- X bugs found
- Y CLAUDE.md violations
- Z security concerns
```

### False positives to ignore

- Pre-existing issues not introduced in this branch
- Issues that look like bugs but aren't (intentional behavior)
- Pedantic nitpicks
- Linter/compiler/type errors (handled by other tools)
- General code quality issues without CLAUDE.md requirement
- Issues with explicit lint-ignore comments
- Intentional functionality changes
- Issues on unmodified lines

### Important notes

- Create a todo list to track progress
- Do NOT attempt to fix issues - only report them
- Do NOT run build/test commands
- Include file:line references for all issues
- Quote relevant code snippets when helpful
