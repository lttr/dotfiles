#!/usr/bin/env bash

# Script to check function usage from functions and aliases files against command history

FUNCTIONS_FILE="./functions"
ALIASES_FILE="./aliases"

if [[ ! -f "$FUNCTIONS_FILE" ]]; then
    echo "Error: functions file not found at $FUNCTIONS_FILE"
    exit 1
fi

if [[ ! -f "$ALIASES_FILE" ]]; then
    echo "Error: aliases file not found at $ALIASES_FILE"
    exit 1
fi

echo "Checking function usage from $FUNCTIONS_FILE and $ALIASES_FILE against atuin history"
echo "================================================================================="

# Extract function names from functions file
# Look for function definitions: funcname() { or function funcname() {
functions_from_functions=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' "$FUNCTIONS_FILE" | sed 's/().*//' | sort -u)

# Extract function names from aliases file  
# Look for function definitions: funcname() { or function funcname() {
functions_from_aliases=$(grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*\(\)' "$ALIASES_FILE" | sed 's/().*//' | sort -u)

# Combine all functions
all_functions=$(echo -e "$functions_from_functions\n$functions_from_aliases" | sort -u | grep -v '^$')

echo "Found $(echo "$all_functions" | wc -l) functions"
echo

# Check usage of functions
echo "Function Usage (sorted by usage count):"
echo "======================================="

used_count=0
unused_count=0

# Create temporary file to store results for sorting
temp_file=$(mktemp)

for func in $all_functions; do
    # Count occurrences in atuin history
    # Use atuin history list and grep for the function as a command (without parentheses)
    # atuin format: timestamp<tab>command<tab>duration, so we check the command column
    count=$(atuin history list | awk -F'\t' '{print $2}' | grep -c "^$func\( \|$\)" 2>/dev/null)
    if [[ $? -ne 0 ]]; then count=0; fi
    
    if [[ $count -gt 0 ]]; then
        printf "%06d ✓ %s: used %d times\n" "$count" "$func" "$count" >> "$temp_file"
        ((used_count++))
    else
        printf "%06d ✗ %s: never used\n" "0" "$func" >> "$temp_file"
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
echo "Used functions: $used_count"
echo "Unused functions: $unused_count"
echo "Total functions: $((used_count + unused_count))"

# Calculate percentage
if [[ $((used_count + unused_count)) -gt 0 ]]; then
    percentage=$((used_count * 100 / (used_count + unused_count)))
    echo "Usage percentage: ${percentage}%"
fi
