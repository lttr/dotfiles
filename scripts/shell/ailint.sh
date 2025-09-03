
#!/usr/bin/env bash

# Auto-detect main branch if not specified
if [[ $# -eq 0 ]]; then
    if git rev-parse --verify main &> /dev/null; then
        BRANCH="main"
    elif git rev-parse --verify master &> /dev/null; then
        BRANCH="master"
    else
        echo "Error: neither 'main' nor 'master' branch exists" >&2
        exit 1
    fi
else
    BRANCH="$1"
fi

if ! command -v claude &> /dev/null; then
    echo "Error: claude command not found" >&2
    exit 1
fi

if ! git rev-parse --git-dir &> /dev/null; then
    echo "Error: not in a git repository" >&2
    exit 1
fi

if ! git rev-parse --verify "$BRANCH" &> /dev/null; then
    echo "Error: branch '$BRANCH' does not exist" >&2
    exit 1
fi

claude -p "You are a linter. Please look at the changes vs. $BRANCH and report any issues related to typos. Report the filename and line number on one line, and a description of the issue on the second line. Do not return any other text."
