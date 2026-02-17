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

attribution=""
if [ "$no_claude" = true ]; then
    attribution=" Do not add Claude attribution to the commits."
fi

# Check if there are staged changes
has_staged=false
if ! git diff --cached --quiet; then
    has_staged=true
fi

# Check if there are unstaged/untracked changes
has_unstaged=false
if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    has_unstaged=true
fi

if [ "$has_staged" = true ]; then
    staged_files=$(git diff --cached --name-status)
    echo 'About to commit STAGED changes only:'
    echo "$staged_files"

    if [ "$has_unstaged" = true ]; then
        echo ''
        echo 'Unstaged changes (NOT to be committed):'
        git diff --name-status
        git ls-files --others --exclude-standard | sed 's/^/??\t/'
    fi

    prompt="Run git commit for the already-staged changes. Do NOT run git add - files are already staged. Only write the commit message and commit.${attribution}

Staged files:
${staged_files}"

    # No git add allowed when files are pre-staged
    allowed_tools='Bash(git commit:*),Bash(git status:*),Bash(git diff:*)'
else
    echo 'About to commit changes (nothing staged, will stage all):'
    git status --short
    prompt="Stage all changes and new files, then commit.${attribution}"
    allowed_tools='Bash(git add:*),Bash(git commit:*),Bash(git status:*),Bash(git diff:*)'
fi

echo ''
claude --allowedTools "$allowed_tools" --model sonnet --print "$prompt" > /dev/null
echo 'Committed:'
git log --oneline -n 1
echo ''
echo 'Next 3 commits:'
git log --oneline HEAD~4..HEAD~1
