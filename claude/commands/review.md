---
description: Choose which code review command to run
---

## Available Review Commands

**Always available:**

| Command | Description |
|---------|-------------|
| `/code-review` | Multi-agent branch review with 5 parallel agents (CLAUDE.md compliance, bugs, git history, security, comments). Confidence scoring, filters to high-confidence issues only. |

**Available when dev-flow plugin enabled:**

| Command | Description |
|---------|-------------|
| `/df:review` | Branch review against base (master/main). Uses data-source-based agents, saves diff to temp file. |
| `/azdo:review` | Azure DevOps PR review (read-only). For reviewing PRs in Azure DevOps. |

## Task

1. Check if dev-flow plugin is enabled by looking for `dev-flow@lttr-claude-marketplace` in `~/.claude/settings.json` under `enabledPlugins`
2. Build options list:
   - Always include `/code-review`
   - If dev-flow enabled, include `/df:review` and `/azdo:review`
3. Ask user which review command to run using AskUserQuestion tool
4. Tell them to run the selected command

Do NOT run the selected command yourself - just inform them which command to use.
