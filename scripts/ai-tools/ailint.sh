
#!/usr/bin/env bash

# Auto-detect main branch if not specified
if [ $# -eq 0 ]; then
    if git show-ref --verify --quiet refs/heads/main; then
        BRANCH="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        BRANCH="master"
    else
        echo "Error: neither 'main' nor 'master' branch exists" >&2
        exit 1
    fi
else
    BRANCH="$1"
fi

prompt="
You are a linter. Look at the changes vs $BRANCH and report any issues related to typos. Follow strictly UNIX error format. Do not return any other text.
<example>
foo.js:5:10: Unexpected foo. [Error/foo]
bar.js:6:11: Unexpected bar. [Warning/bar]
</example>
"

# Run claude and capture output
output=$(claude -p "$prompt")

# Display the output
echo "$output"

# Exit with error code if issues found
if echo "$output" | grep -q "^[^:]*:[0-9]*:"; then
    exit 1
else
    exit 0
fi
