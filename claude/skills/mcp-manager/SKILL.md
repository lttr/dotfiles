---
name: mcp-manager
description: Manage MCP (Model Context Protocol) servers in Claude Code projects. Use this skill when the user requests enabling, installing, disabling, or removing specific MCP servers like context7 or chrome-devtools. Always operates at project level (local scope only).
---

# MCP Manager

## Overview

Manage MCP servers in Claude Code projects by enabling, installing, disabling, or removing specific servers. **This skill ALWAYS operates at the project level (local scope only)** - all MCP changes are project-specific and not shared via git.

## Available MCP Servers

### context7
Library documentation server providing up-to-date code examples and API references.

**Enable/Install:**
```bash
~/dotfiles/claude/skills/mcp-manager/scripts/mcp-enable-context7.sh
```

**Disable/Remove:**
```bash
claude mcp remove context7 --scope local
```

### chrome-devtools
Browser automation and debugging server using Chrome DevTools Protocol.

**Enable/Install:**
```bash
~/dotfiles/claude/skills/mcp-manager/scripts/mcp-enable-chrome-devtools.sh
```

**Disable/Remove:**
```bash
claude mcp remove chrome-devtools --scope local
```

### nuxt-ui
Nuxt UI documentation server providing components, composables, examples, and templates via HTTP.

**Enable/Install:**
```bash
~/dotfiles/claude/skills/mcp-manager/scripts/mcp-enable-nuxt-ui.sh
```

**Disable/Remove:**
```bash
claude mcp remove nuxt-ui --scope local
```

## Usage Workflow

### Enabling/Installing MCP Servers

When the user requests enabling or installing an MCP server:

1. Identify which MCP server(s) to enable
2. Execute the corresponding script from `scripts/`
3. Confirm successful installation

**Example user requests:**
- "Enable context7 MCP in this project"
- "Install chrome-devtools MCP"
- "Add context7"
- "Set up chrome-devtools"

### Disabling/Removing MCP Servers

When the user requests disabling or removing an MCP server:

1. Identify which MCP server(s) to remove
2. Run `claude mcp remove <server-name> --scope local`
3. Confirm successful removal

**Example user requests:**
- "Disable context7 MCP"
- "Remove chrome-devtools"
- "Uninstall context7"

## Scripts

All enable scripts install MCPs with `--scope local`, meaning:
- Local scope: Project-specific, not shared via git

Transport types:
- Stdio transport: Runs locally via npx (context7, chrome-devtools)
- HTTP transport: Connects to remote server (nuxt-ui)

Available scripts:
- `~/dotfiles/claude/skills/mcp-manager/scripts/mcp-enable-context7.sh` - Install @upstash/context7-mcp (stdio)
- `~/dotfiles/claude/skills/mcp-manager/scripts/mcp-enable-chrome-devtools.sh` - Install chrome-devtools-mcp (stdio)
- `~/dotfiles/claude/skills/mcp-manager/scripts/mcp-enable-nuxt-ui.sh` - Connect to nuxt-ui remote server (HTTP)

For disabling, use `claude mcp remove <server-name> --scope local` directly
