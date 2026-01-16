---
allowed-tools: Bash(git:*), Bash(fd:*), Read, Glob, Grep, Task
description: Recall project context and resume work on a dormant repo
argument-hint: [deep]
---

## Context

- Current working directory: !`pwd`
- Git root: !`git rev-parse --show-toplevel 2>/dev/null || echo "Not a git repository"`
- Current branch: !`git branch --show-current 2>/dev/null`
- Last commit date: !`git log -1 --format="%ar (%ci)" 2>/dev/null || echo "No commits"`

## Task

Help the user resume work on a project they haven't touched recently. Gather and present project context in a scannable format.

**Arguments (`$ARGUMENTS`):**

- `deep` - Run thorough codebase exploration using Explore agent (slower)

## Workflow

### 1. Git State (always run)

Gather in parallel:
- `git status` - uncommitted changes
- `git stash list` - stashed work
- `git branch -a` - all branches (highlight feature/wip branches)
- `git log --oneline -15 --date=short --format="%h %ad %s"` - recent commits with dates
- `git log -1 --format="%ar"` - time since last commit
- `git rev-list --count @{u}..HEAD 2>/dev/null` - unpushed commits (if tracking remote)

### 2. Project Context (always run)

Detect project type and show key info:
- Check for: `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pyproject.toml`
- If `package.json`: show name, scripts available
- If README exists: summarize purpose (first paragraph)
- Check `.aitools/plans/` for existing plans - list recent ones

### 3. Work-in-Progress Signals (quick scan)

- Count TODO/FIXME in codebase: `rg -c "TODO|FIXME" --type-not lock 2>/dev/null | wc -l`
- Identify WIP/feature branches from branch list

### 4. Deep Analysis (only if `deep`)

If `$ARGUMENTS` contains `deep`:
- Use Task tool with `subagent_type=Explore` to understand:
  - Project architecture and key entry points
  - Main components/modules
  - Testing setup
  - Build/dev workflow

## Output Format

Present findings as:

```
## Quick Status
- **Branch:** main (3 uncommitted files)
- **Last activity:** 2 weeks ago
- **Stashed:** 1 stash

## Recent Activity
[Table or list of last 10-15 commits with dates]

## Open Branches
- feature/auth-flow (ahead of main by 5 commits)
- fix/login-bug

## Project
- **Type:** Node.js (package.json)
- **Scripts:** dev, build, test, lint
- **TODOs:** 12 across codebase

## Existing Plans
- 2024-12-15_auth-refactor.md
- 2024-12-10_api-design.md

## Suggested Actions
1. [Based on analysis - what to do next]
```

Keep output scannable. Use tables where appropriate. Front-load most important info.

## Rules

- Do NOT make any changes to the repo
- Do NOT run install/build commands
- Be fast by default - only do deep analysis if `deep` argument provided
- If not a git repo, still show project context where possible
