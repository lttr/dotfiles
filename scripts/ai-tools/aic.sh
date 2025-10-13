#!/usr/bin/env bash

# AI-powered git commit helper
# Shows current changes, generates commit message using Claude, and displays recent commits

# Parse command line arguments
no_claude=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--no-claude)
            no_claude=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-n|--no-claude]"
            exit 1
            ;;
    esac
done

if [ "$no_claude" = true ]; then
    prompt="git commit. If there are staged files, only commit those, otherwise stage all changes and new files and commit. Do not add Claude attribution to the commits."
else
    prompt="git commit. If there are staged files, only commit those, otherwise stage all changes and new files and commit."
fi

echo 'About to commit changes:'
# Check if there are staged changes
if git diff --cached --quiet; then
    # No staged changes, show all changes
    git status --short
else
    # Show only staged changes
    git diff --cached --name-status
fi
echo ''
claude --allowedTools 'Bash(git add:*),Bash(git commit:*),Bash(git status:*),Bash(git diff:*)' --print "$prompt" > /dev/null
echo 'Committed:'
git log --oneline -n 1
echo ''
echo 'Next 3 commits:'
git log --oneline HEAD~4..HEAD~1
