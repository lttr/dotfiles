#!/usr/bin/env bash
# Enable nuxt-ui MCP server locally in current project

set -e

claude mcp add nuxt-ui \
  --scope local \
  --transport http \
  -- https://ui.nuxt.com/mcp

echo "✓ Enabled nuxt-ui MCP (local scope, HTTP transport)"
