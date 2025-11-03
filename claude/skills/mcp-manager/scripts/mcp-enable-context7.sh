#!/usr/bin/env bash
# Enable context7 MCP server locally in current project

set -e

claude mcp add context7 \
  --scope local \
  --transport stdio \
  -- npx -y @upstash/context7-mcp

echo "✓ Enabled context7 MCP (local scope)"
