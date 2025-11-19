---
allowed-tools: Task
description: List all built-in Claude Code slash commands
---

## Context

Show all built-in slash commands available in Claude Code's interactive mode.

## Your task

Use the Task tool with the claude-code-guide subagent to retrieve the list of built-in commands:

subagent_type: claude-code-guide
prompt: "What are all the built-in interactive mode commands (slash commands) available in Claude Code? List them in categories with descriptions."
model: haiku
