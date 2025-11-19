---
description: List all available Task tool subagent types
---

Extract all built-in Task tool subagent types from your system prompt's Task tool definition (look for "Available agent types and the tools they have access to").

First, check `~/.claude/agents/` for any .md files to get the list of custom agent names.

Then for each built-in agent type (excluding any custom agent names), show:
- Name
- Purpose (1 line)
- Available tools

Use compact bullet format.
