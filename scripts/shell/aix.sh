#!/usr/bin/env bash

# Prepare a command for execution using Claude
input="$*"
prompt="
You are a command line expert. Given a task, respond with a oneliner, that can
be executed in Bash shell and would satisfy task instructions. I value readable
output, long variant of arguments. DO output 2 lines: first line with short
explanation of its arguments and second line with the oneliner command. Never
output markdown.
<example>
List directory contents [ls -l] a long listing format [ls -t] sort by modification time, newest first
ls -lt
</example>
"

# Get Claude's response
response=$(claude -p "$prompt Task: $input")

# Add blank line at the beginning
echo ""

# Split response into lines and color appropriately
IFS=$'\n' read -rd '' -a lines <<< "$response"

if [[ ${#lines[@]} -ge 2 ]]; then
    # Color first line dimmed gray
    echo -e "\033[2;37m${lines[0]}\033[0m"
    
    command="${lines[1]}"
    xdotool type "$command"
else
    # Fallback if response doesn't have expected format
    echo "$response"
fi
