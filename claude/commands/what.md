---
description: List available commands for listing tools and features and context
allowed-tools: Bash
---

# Available Meta-Commands

Commands for discovering what Claude Code can do:

## Built-in Commands

- `/agents` - List available agent types
- `/hooks` - List configured hooks
- `/memory` - View conversation memory
- `/mcp` - List MCP server connections
- `/plugins` - List installed plugins
- `/todos` - Display current task items
- `/status` - View version, model, account, and connectivity details
- `/output-style` - Check or adjust output formatting
- `/permissions` - Control and review access permissions

## Custom List Commands

Run this command and display the output:

```bash
head -n 3 ~/dotfiles/claude/commands/list/*.md
```
