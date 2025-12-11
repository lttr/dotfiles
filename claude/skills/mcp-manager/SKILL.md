---
name: mcp-manager
description: Add or remove MCP (Model Context Protocol) servers to local project scope. Use this skill when the user wants to add or remove specific MCP servers like context7 or chrome-devtools for the current project. For enabling/disabling or global MCP management, direct users to use the native /mcp command.
---

# MCP Manager

## Overview

Add or remove MCP servers at the **local project level only**. This skill handles project-specific MCP configuration that isn't shared via git.

## Scope

**This skill handles:**
- Adding MCP servers to current project (local scope)
- Removing MCP servers from current project (local scope)

**This skill does NOT handle (redirect to `claude mcp` CLI):**
- Enabling/disabling MCP servers
- Global or user-level MCP configuration
- Listing available MCP servers
- MCP server status/diagnostics

When user asks about enabling, disabling, or global MCP management, respond:
> "For enabling/disabling MCP servers or global configuration, use `claude mcp` in your terminal which provides full MCP management."

## Available MCP Servers

### context7
Library documentation server providing up-to-date code examples and API references.

**Add to project:**
```bash
~/dotfiles/claude/skills/mcp-manager/scripts/mcp-add-context7.sh
```

**Remove from project:**
```bash
claude mcp remove context7 --scope local
```

### chrome-devtools
Browser automation and debugging server using Chrome DevTools Protocol.

**Add to project:**
```bash
~/dotfiles/claude/skills/mcp-manager/scripts/mcp-add-chrome-devtools.sh
```

**Remove from project:**
```bash
claude mcp remove chrome-devtools --scope local
```

### nuxt-ui
Nuxt UI documentation server providing components, composables, examples, and templates via HTTP.

**Add to project:**
```bash
~/dotfiles/claude/skills/mcp-manager/scripts/mcp-add-nuxt-ui.sh
```

**Remove from project:**
```bash
claude mcp remove nuxt-ui --scope local
```

## Usage

### Adding MCP Servers

When user requests adding an MCP server to the project:

1. Identify which MCP server(s) to add
2. Execute the corresponding script from `scripts/`
3. Confirm successful addition

**Example user requests:**
- "Add context7 to this project"
- "Install chrome-devtools MCP here"
- "Set up nuxt-ui MCP for this repo"

### Removing MCP Servers

When user requests removing an MCP server from the project:

1. Identify which MCP server(s) to remove
2. Run `claude mcp remove <server-name> --scope local`
3. Confirm successful removal

**Example user requests:**
- "Remove context7 from this project"
- "Uninstall chrome-devtools MCP"

### Redirecting Other Requests

For requests about enabling, disabling, listing, or global management:

> "Use `claude mcp` in your terminal for that - it provides full MCP server management including enable/disable, listing, and global configuration."

## Scripts

All add scripts use `--scope local` (project-specific, not shared via git).

Transport types:
- **Stdio**: Runs locally via npx (context7, chrome-devtools)
- **HTTP**: Connects to remote server (nuxt-ui)
