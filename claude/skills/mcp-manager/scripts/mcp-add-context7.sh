#!/usr/bin/env bash
# Add context7 MCP server to current project (local scope)

set -e

claude mcp add context7 \
  --scope local \
  --transport stdio \
  -- npx -y @upstash/context7-mcp

echo "✓ Added context7 MCP to project (local scope)"
