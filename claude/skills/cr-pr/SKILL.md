---
name: cr-pr
description: Review a PR, ticket, or the current branch in an isolated worktree. Accepts a PR id or URL, a ticket number, or nothing (current branch).
context: fork
agent: worktree-reviewer
disable-model-invocation: true
---

Review `$ARGUMENTS` (a PR id or URL, a ticket number, or empty for the user's current branch). Follow your agent instructions: resolve what to review, check it out in your worktree, run the review, report findings.
