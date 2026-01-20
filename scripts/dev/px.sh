#!/usr/bin/env bash
# pnpm exec with fallback to dlx
pnpm exec "$@" 2>/dev/null || pnpm dlx "$@"
