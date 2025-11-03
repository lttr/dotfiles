#!/usr/bin/env bash
# Enable chrome-devtools MCP server locally in current project

set -e

claude mcp add chrome-devtools \
  --scope local \
  --transport stdio \
  -- npx -y chrome-devtools-mcp@latest

echo "✓ Enabled chrome-devtools MCP (local scope)"
