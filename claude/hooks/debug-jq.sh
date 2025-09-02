#!/bin/bash

# Debug script to see what jq is receiving
echo "Debug: stdin received by jq:" >&2
cat | tee /tmp/jq-debug-input.json | jq -r '.tool_input.file_path'