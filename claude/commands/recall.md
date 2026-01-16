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
- `git status` - uncommitted changes (summarize by filename, not full paths)
- `git stash list` - stashed work (include stash message)
- `git branch -a` - all branches (filter to feature/wip branches only)
- `git log --oneline -5 --date=short --format="%h %ad %s"` - last 5 commits max
- `git log -1 --format="%ar"` - time since last commit
- `git rev-list --count @{u}..HEAD 2>/dev/null` - unpushed commits (if tracking remote)

### 2. Project Context (always run)

Detect project type and show key info:
- Check for: `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pyproject.toml`
- If `package.json`: show name, scripts available
- If README exists: summarize purpose (first paragraph)

### 3. Filter Unfinished Plans

For each plan in `.aitools/plans/`:
1. Read the plan file to identify key features/components it describes
2. Search git log and codebase for evidence it's implemented:
   - Commit messages mentioning the feature
   - Files/functions the plan describes actually existing
   - Related branches merged to main
3. Categorize: "not started", "in progress", "likely done"
4. Only show "not started" and "in progress" plans

### 4. Work-in-Progress Signals (quick scan)

- Count TODO/FIXME in codebase: `rg -c "TODO|FIXME" --type-not lock 2>/dev/null | wc -l`
- Identify WIP/feature branches from branch list

### 5. Deep Analysis (only if `deep`)

If `$ARGUMENTS` contains `deep`:
- Use Task tool with `subagent_type=Explore` to understand:
  - Project architecture and key entry points
  - Main components/modules
  - Testing setup
  - Build/dev workflow

## Output Format

Present findings as:

```
## Resume Point
[1-2 sentences: What was being worked on + suggested next action]
Example: "Last touched auth flow. Stash has schema changes. → Apply stash or continue with video support plan?"

## Working State
[Only show if there ARE uncommitted changes, stashes, or unpushed commits]
- Modified: server/api/albums.ts, components/Gallery.vue
- Stash: "schema reorganization WIP" (1 stash)
- Unpushed: 3 commits

## Unfinished Plans
[Only show plans that appear NOT yet implemented - cross-reference plan content with recent commits/branches]
- video-lightbox (phase 5) - not started
- background-jobs - partially done (queue system merged, workers pending)

## WIP Branches
[Feature/fix branches not yet merged]
- feature/video-upload (5 commits ahead)

## Last 3 Commits
abc1234 2026-01-03 fix(admin): responsive toolbar
def5678 2026-01-03 fix(auth): await session fetch
ghi9012 2026-01-03 fix(album): loading flash
```

**Key principles:**
- Resume Point = #1 priority, immediately actionable
- Hide sections with nothing to show
- Plans: read plan files, check if main features exist in codebase/git history
- Git log: max 3-5 commits, just for orientation
- Front-load decisions/actions, not historical data

## Rules

- Do NOT make any changes to the repo
- Do NOT run install/build commands
- Be fast by default - only do deep analysis if `deep` argument provided
- If not a git repo, still show project context where possible
