#!/usr/bin/env bash

# AI-powered git commit helper
# Shows current changes, generates commit message using Claude, and displays recent commits

prompt="just commit, no questions asked"

echo 'About to commit changes:'
git status --short
echo ''
claude --allowedTools 'Bash(git add:*),Bash(git commit:*),Bash(git status:*),Bash(git diff:*)' --print "$prompt" > /dev/null
echo 'Committed:'
git log --oneline -n 1
echo ''
echo 'Next 3 commits:'
git log --oneline HEAD~4..HEAD~1
