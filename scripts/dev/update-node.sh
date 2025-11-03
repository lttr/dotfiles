#!/usr/bin/env zsh

# Update Node.js to latest LTS version and save to .node-version
# Usage: update-node.sh

set -e

echo "Installing latest LTS version of Node.js..."
fnm install --lts

echo "Switching to LTS..."
fnm use lts-latest

echo "Writing version to .node-version..."
node --version > .node-version

echo "Node.js updated to $(node --version)"
cat .node-version
