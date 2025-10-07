---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git commit:*), Bash(git show:*), Bash(git rev-parse:*), Bash(git rev-list:*)
description: Create a git commit with intelligent message generation
argument-hint: [commit message] [no-claude]
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create git commits following the standard Claude commit workflow.

**Arguments handling:**

- If `$ARGUMENTS` contains a message (excluding "no-claude" and "multi") you should consider the message during the commit workflow
- If `$ARGUMENTS` contains "no-claude" anywhere, omit the Claude attribution from the commit message(s)

**Commit behavior:**

- Stage changes and write a set of logical commits for them, or only a single commit if the changes are cohesive
- Show initial status with `git status --short`
- Record initial commit with `git rev-parse HEAD`
- After creating commits, show summary of new commits created
- Display new commits with `git log --oneline` and recent commits for context
- Return only the first line of the commit message(s) for brevity

**Attribution:**

- By default, include the standard Claude attribution:

```
🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

- If "no-claude" appears in `$ARGUMENTS`, omit the attribution
