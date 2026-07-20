---
name: cr-pr
description: Review a PR, ticket, or the current branch in an isolated worktree. Accepts a PR id or URL, a ticket number, or nothing (current branch). Optional `--skill <name>` picks the review skill to run.
context: fork
agent: worktree-reviewer
disable-model-invocation: true
---

Review `$ARGUMENTS` (a PR id or URL, a ticket number, or empty for the user's current branch). If the arguments contain `--skill <name>` or a slash-prefixed token like `/df:code-review`, that names the review skill to execute; strip it from the review target. Follow your agent instructions: resolve what to review, check it out in your worktree, run the review, report findings.
