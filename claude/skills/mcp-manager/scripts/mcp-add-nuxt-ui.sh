#!/usr/bin/env bash
# Add nuxt-ui MCP server to current project (local scope)

set -e

claude mcp add nuxt-ui \
  --scope local \
  --transport http \
  -- https://ui.nuxt.com/mcp

echo "✓ Added nuxt-ui MCP to project (local scope, HTTP transport)"
