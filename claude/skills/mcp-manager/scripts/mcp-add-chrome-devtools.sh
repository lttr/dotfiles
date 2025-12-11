#!/usr/bin/env bash
# Add chrome-devtools MCP server to current project (local scope)

set -e

claude mcp add chrome-devtools \
  --scope local \
  --transport stdio \
  -- npx -y chrome-devtools-mcp@latest

echo "✓ Added chrome-devtools MCP to project (local scope)"
