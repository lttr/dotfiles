#!/usr/bin/env bash

# Prepare a command for execution using Claude
input="$*"
prompt="
You are a command line expert. Given a task, respond with a oneliner, that can
be executed in Bash shell and would satisfy task instructions. I value readable
output, long variant of arguments. DO output 2 lines: first line with short
explanation of its arguments and second line with the oneliner command. Never
output markdown.
<example-output>
List directory contents [ls -l] a long listing format [ls -t] sort by modification time, newest first
ls -lt
</example-output>
"

# Get Claude's response
response=$(claude -p "${prompt} Task: ${input}")

# Add blank line at the beginning
echo ""

# Split response into lines and color appropriately
IFS=$'\n' read -rd '' -a lines <<< "$response"

if [[ ${#lines[@]} -ge 2 ]]; then
    # Color first line dimmed gray, second line magenta
    echo "\033[2;37m${lines[1]}\033[0m"
    echo "\033[35m${lines[2]}\033[0m"
    
    command="${lines[2]}"

    # Ask user what to do
    while true; do
        echo ""
        echo -n "\033[32m Execute (y), Edit (e), Follow-up (f), or Cancel (c/n)? [y/e/f/c]: \033[0m"
        read "choice?"
        echo ""
        case $choice in
            [Yy]*) 
                echo "Executing: $command"
                eval "$command"
                exit 0
                ;;
            [Ee]*) 
                # Assumes editor is nvim
                # Open command in editor for modification
                temp_file=$(mktemp)
                echo "$command" > "$temp_file"
                ${EDITOR:-nvim} "$temp_file" +"set filetype=bash" < /dev/tty
                edited_command=$(cat "$temp_file")
                rm -f "$temp_file"
                
                if [[ -n "$edited_command" ]]; then
                    # Update command with edited version and continue the loop
                    command="$edited_command"
                    echo "Edited command: $command"
                else
                    echo "Empty command. Cancelled."
                    exit 1
                fi
                ;;
            [Ff]*) 
                # Follow-up question to Claude
                echo -n "\033[2;32mFollow-up question: \033[0m"
                read "followup?"
                if [[ -n "$followup" ]]; then
                    echo ""
                    followup_response=$(claude -pc "$followup")
                    echo ""
                    # Split response into lines and color appropriately
                    IFS=$'\n' read -rd '' -a followup_lines <<< "$followup_response"
                    if [[ ${#followup_lines[@]} -ge 2 ]]; then
                        # Color first line dimmed gray, second line magenta
                        echo "\033[2;37m${followup_lines[1]}\033[0m"
                        echo "\033[35m${followup_lines[2]}\033[0m"
                        # Update command with follow-up response
                        command="${followup_lines[2]}"
                    else
                        # Fallback if response doesn't have expected format
                        echo "$followup_response"
                    fi
                fi
                ;;
            [CcNn]*) 
                echo "Cancelled"
                exit 1
                ;;
            *) 
                echo "Please enter 'y' for execute, 'e' for edit, 'f' for follow-up, or 'c' for cancel"
                ;;
        esac
    done
else
    # Fallback if response doesn't have expected format
    echo "$response"
fi
