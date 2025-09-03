#!/usr/bin/env bash

# AI-powered git commit helper
# Shows current changes, generates commit message using Claude, and displays recent commits

prompt="just commit, no questions asked, DO NOT OUTPUT ANY CONFIRMATION"

echo 'About to commit changes:'
git status --short
echo ''
claude --allowedTools 'Bash(git add:*),Bash(git commit:*),Bash(git status:*),Bash(git diff:*)' --print "$prompt"
echo 'Last 3 commits:'
git log --oneline -n 3
