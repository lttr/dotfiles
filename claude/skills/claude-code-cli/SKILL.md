---
name: claude-code-cli
description: Reference guide for Claude Code CLI commands, flags, and configuration. Use this skill when users ask about CLI options, need help constructing complex command invocations, or are troubleshooting CLI behavior.
---

# Claude Code CLI

## Getting CLI Information

### Quick Reference
```bash
claude --help
```

### Documentation
Use WebFetch to access official docs:

**Primary Docs:**
- `https://docs.claude.com/en/docs/claude-code/cli-reference.md` - Complete CLI reference
- `https://docs.claude.com/en/docs/claude-code/interactive-mode.md` - Keyboard shortcuts, vim mode
- `https://docs.claude.com/en/docs/claude-code/model-config.md` - Model selection
- `https://docs.claude.com/en/docs/claude-code/claude_code_docs_map.md` - Complete docs index

## Common Usage Patterns

### Interactive vs Print Mode

**Interactive (default):**
```bash
claude                    # Start session
claude -c                 # Continue last
claude -r [sessionId]     # Resume specific
```

**Print Mode:**
```bash
claude -p "query"         # Single query
```

**Note:** Print mode skips workspace trust dialog.

### Key Flags

Run `claude --help` for complete list. Common examples:

```bash
--model <model>           # sonnet, opus, haiku
--tools <tools>           # Specify or disable tools
--allowedTools <tools>    # Pre-approve tools
--append-system-prompt    # Add to system prompt
--permission-mode <mode>  # default, acceptEdits, bypassPermissions, plan
```

### Management Commands

```bash
claude update             # Check updates
claude mcp                # Configure MCP servers
claude plugin             # Manage plugins
```

## Workflow

When users ask about CLI functionality:

1. Check `claude --help` for current flags
2. Use WebFetch for detailed docs if needed
3. Provide concrete examples
4. Note limitations when relevant

## Security Notes

- Print mode (`-p`) skips workspace trust dialog
- Use `--dangerously-skip-permissions` only in sandboxed environments
- Pre-approve tools carefully with `--allowedTools`

## Config Files

- Global: `~/.config/Claude/settings.json`
- Project: `.claude/settings.json`
- MCP: `~/.config/Claude/mcp.json` and `.claude/mcp.json`
