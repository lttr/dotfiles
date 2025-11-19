---
description: List all MCP server tools
---

## Context

Claude Code can connect to MCP (Model Context Protocol) servers that provide additional tools. Users may want to see what MCP tools are currently available.

## Your task

List all MCP tools (tools that start with `mcp__`).

For each tool, provide:

- Tool name in `code-formatted` style
- Brief description (one line)
- Which MCP server provides it (extract from tool name prefix)

Organize by MCP server.

If no MCP servers are configured, inform the user and suggest running `claude mcp` or visiting https://docs.claude.com/en/docs/claude-code/mcp to learn more.

Use compact format with minimal formatting.
