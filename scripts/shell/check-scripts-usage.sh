#!/usr/bin/env bash

# Script to check script usage from scripts directory against command history

SCRIPTS_DIR="$HOME/dotfiles/scripts"

if [[ ! -d "$SCRIPTS_DIR" ]]; then
    echo "Error: scripts directory not found at $SCRIPTS_DIR"
    exit 1
fi

echo "Checking script usage from $SCRIPTS_DIR against atuin history"
echo "=============================================================="

# Find all executable shell scripts in scripts directory
scripts=$(find "$SCRIPTS_DIR" -type f -name "*.sh" -executable | sort)

if [[ -z "$scripts" ]]; then
    echo "No executable shell scripts found in $SCRIPTS_DIR"
    exit 0
fi

echo "Found $(echo "$scripts" | wc -l) executable shell scripts"
echo

# Check usage of scripts
echo "Script Usage (sorted by usage count):"
echo "====================================="

used_count=0
unused_count=0

# Create temporary file to store results for sorting
temp_file=$(mktemp)

for script_path in $scripts; do
    # Get script name without path and extension (as created by symlink-scripts.sh)
    script_name=$(basename "$script_path")
    script_name="${script_name%.*}"
    
    # Count occurrences in atuin history
    # Check for both the script name (symlinked version) and full path
    # Use atuin history list and grep for the script as a command
    name_count=$(atuin history list | awk -F'\t' '{print $2}' | grep -c "^$script_name\( \|$\)" 2>/dev/null)
    path_count=$(atuin history list | awk -F'\t' '{print $2}' | grep -c "$script_path" 2>/dev/null)
    
    # Also check for relative path usage from dotfiles directory
    relative_path="scripts/${script_path#$HOME/dotfiles/scripts/}"
    relative_count=$(atuin history list | awk -F'\t' '{print $2}' | grep -c "$relative_path" 2>/dev/null)
    
    total_count=$((name_count + path_count + relative_count))
    
    if [[ $total_count -gt 0 ]]; then
        usage_info=""
        if [[ $name_count -gt 0 ]]; then
            usage_info+="name: $name_count"
        fi
        if [[ $path_count -gt 0 ]]; then
            if [[ -n "$usage_info" ]]; then usage_info+=", "; fi
            usage_info+="path: $path_count"
        fi
        if [[ $relative_count -gt 0 ]]; then
            if [[ -n "$usage_info" ]]; then usage_info+=", "; fi
            usage_info+="relative: $relative_count"
        fi
        
        printf "%06d ✓ %s: used %d times (%s)\n" "$total_count" "$script_name" "$total_count" "$usage_info" >> "$temp_file"
        ((used_count++))
    else
        printf "%06d ✗ %s: never used\n" "0" "$script_name" >> "$temp_file"
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
echo "Used scripts: $used_count"
echo "Unused scripts: $unused_count"
echo "Total scripts: $((used_count + unused_count))"

# Calculate percentage
if [[ $((used_count + unused_count)) -gt 0 ]]; then
    percentage=$((used_count * 100 / (used_count + unused_count)))
    echo "Usage percentage: ${percentage}%"
fi