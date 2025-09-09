#!/usr/bin/env bash

# AI-powered git commit helper - multiple commits
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
    prompt="Stage my changes and write a set of commits for them. Do not add Claude attribution to the commits."
else
    prompt="Stage my changes and write a set of commits for them."
fi

echo 'Going to to do several commits with these changed files:'
git status --short
echo ''
initial_commit=$(git rev-parse HEAD)
claude --allowedTools 'Bash(git add:*),Bash(git commit:*),Bash(git status:*),Bash(git diff:*)' --print "$prompt"
echo ''
new_commits=$(git rev-list ${initial_commit}..HEAD --count)
if [ "$new_commits" -gt 0 ]; then
    echo "New commits created ($new_commits):"
    git log --oneline ${initial_commit}..HEAD
    echo ''
    echo 'Last 3 commits before new ones:'
    git log --oneline -n 3 $initial_commit
else
    echo 'No new commits created.'
    echo ''
    echo 'Last 7 commits:'
    git log --oneline -n 7
fi
