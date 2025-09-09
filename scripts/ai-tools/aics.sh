#!/usr/bin/env bash

# AI-powered git commit helper - multiple commits
# Shows current changes, generates commit message using Claude, and displays recent commits

prompt="Stage my changes and write a set of commits for them." 

echo 'Going to to do several commits with these changed files:'
git status --short
echo ''
claude --allowedTools 'Bash(git add:*),Bash(git commit:*),Bash(git status:*),Bash(git diff:*)' --print "$prompt" > /dev/null
echo ''
echo 'Last 7 commits:'
git log --oneline -n 7
