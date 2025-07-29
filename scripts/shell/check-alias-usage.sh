#!/usr/bin/env bash

# Script to check alias usage from aliases file against command history

ALIASES_FILE="./aliases"

if [[ ! -f "$ALIASES_FILE" ]]; then
    echo "Error: aliases file not found at $ALIASES_FILE"
    exit 1
fi

echo "Checking alias usage from $ALIASES_FILE against atuin history"
echo "================================================================"

# Extract aliases from the aliases file (excluding commented ones and functions)
aliases=$(grep -E '^alias [a-zA-Z]' "$ALIASES_FILE" | sed 's/^alias //' | cut -d'=' -f1 | sort -u)

# Also extract global aliases
global_aliases=$(grep -E '^\s*alias -g [A-Z]' "$ALIASES_FILE" | sed 's/.*alias -g //' | cut -d'=' -f1 | sort -u)

echo "Found $(echo "$aliases" | wc -l) regular aliases and $(echo "$global_aliases" | wc -l) global aliases"
echo

# Check usage of regular aliases
echo "Regular Alias Usage (sorted by usage count):"
echo "============================================="

used_count=0
unused_count=0

# Create temporary file to store results for sorting
temp_file=$(mktemp)

for alias in $aliases; do
    # Count occurrences in atuin history
    # Use atuin history list and grep for the alias as a command
    count=$(atuin history list | grep -c "^$alias\( \|$\)" 2>/dev/null)
    if [[ $? -ne 0 ]]; then count=0; fi
    
    if [[ $count -gt 0 ]]; then
        printf "%06d ✓ %s: used %d times\n" "$count" "$alias" "$count" >> "$temp_file"
        ((used_count++))
    else
        printf "%06d ✗ %s: never used\n" "0" "$alias" >> "$temp_file"
        ((unused_count++))
    fi
done

# Sort by count (descending) and display
sort -nr "$temp_file" | sed 's/^[0-9]* //'

# Clean up
rm "$temp_file"

echo
echo "Summary:"
echo "========"
echo "Used aliases: $used_count"
echo "Unused aliases: $unused_count"
echo "Total regular aliases: $((used_count + unused_count))"

# Calculate percentage
if [[ $((used_count + unused_count)) -gt 0 ]]; then
    percentage=$((used_count * 100 / (used_count + unused_count)))
    echo "Usage percentage: ${percentage}%"
fi
