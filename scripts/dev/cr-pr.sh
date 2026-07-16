#!/usr/bin/env bash
# cr-pr [pr-id|pr-url|ticket] — review a PR, ticket, or current branch in an isolated worktree via the global /cr-pr skill.

set -euo pipefail

exec claude --permission-mode auto "/cr-pr ${1:-}"
