#!/bin/bash

# Script to check git repositories in subfolders for Nuxt, Vue, and AI tooling usage
# Usage: ./check-nuxt-repos.sh

set -e

echo "=== Git Repository Analysis ==="
echo "Checking repositories in subfolders..."
echo ""

# Function to check if a directory is a git repository
is_git_repo() {
    [ -d "$1/.git" ]
}

# Function to get package.json value
get_package_version() {
    local package_json="$1"
    local package_name="$2"
    
    if [ -f "$package_json" ]; then
        # Check both dependencies and devDependencies
        local version=$(jq -r "(.dependencies[\"$package_name\"] // .devDependencies[\"$package_name\"] // empty)" "$package_json" 2>/dev/null)
        if [ "$version" != "null" ] && [ -n "$version" ]; then
            echo "$version"
        else
            echo "not found"
        fi
    else
        echo "no package.json"
    fi
}

# Function to check if CLAUDE.md exists
check_claude_md() {
    local dir="$1"
    if [ -f "$dir/CLAUDE.md" ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# Function to get last commit date in Czech format
get_last_commit_date() {
    local repo_dir="$1"
    if [ -d "$repo_dir/.git" ]; then
        cd "$repo_dir"
        local commit_date=$(git log -1 --format=%cd --date=format:'%d.%m.%Y' 2>/dev/null)
        cd - > /dev/null
        if [ -n "$commit_date" ]; then
            echo "$commit_date"
        else
            echo "unknown"
        fi
    else
        echo "no git"
    fi
}

# Main analysis function
analyze_repo() {
    local repo_dir="$1"
    local repo_name=$(basename "$repo_dir")
    
    echo "Repository: $repo_name"
    
    local package_json="$repo_dir/package.json"
    local nuxt_version=$(get_package_version "$package_json" "nuxt")
    local vue_version=$(get_package_version "$package_json" "vue")
    local has_claude=$(check_claude_md "$repo_dir")
    local last_commit=$(get_last_commit_date "$repo_dir")
    
    echo "  Nuxt version: $nuxt_version"
    echo "  Vue version: $vue_version"
    echo "  AI tooling (CLAUDE.md): $has_claude"
    echo "  Last commit: $last_commit"
    echo ""
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Counter for repositories found
repo_count=0
nuxt_repos=0

# Array to store nuxt repositories with their last commit timestamps for sorting
declare -a nuxt_repo_list=()

# Scan subdirectories (1 level deep)
for dir in */; do
    if [ -d "$dir" ] && is_git_repo "$dir"; then
        repo_count=$((repo_count + 1))
        
        # Check if it's a Nuxt project
        package_json="$dir/package.json"
        if [ -f "$package_json" ]; then
            nuxt_check=$(jq -r '(.dependencies.nuxt // .devDependencies.nuxt // empty)' "$package_json" 2>/dev/null)
            if [ "$nuxt_check" != "null" ] && [ -n "$nuxt_check" ]; then
                nuxt_repos=$((nuxt_repos + 1))
                
                # Get last commit timestamp for sorting
                cd "$dir"
                commit_timestamp=$(git log -1 --format=%ct 2>/dev/null || echo "0")
                cd - > /dev/null
                
                # Store repo info with timestamp for sorting
                nuxt_repo_list+=("$commit_timestamp:$dir")
            fi
        fi
    fi
done

# Sort repositories by last commit timestamp (most recent first) and analyze
IFS=$'\n' sorted_repos=($(sort -t: -k1,1nr <<< "${nuxt_repo_list[*]}"))
for repo_entry in "${sorted_repos[@]}"; do
    repo_dir="${repo_entry#*:}"
    analyze_repo "$repo_dir"
done

echo "=== Summary ==="
echo "Total git repositories found: $repo_count"
echo "Repositories using Nuxt: $nuxt_repos"

if [ $repo_count -eq 0 ]; then
    echo "No git repositories found in subdirectories."
elif [ $nuxt_repos -eq 0 ]; then
    echo "No Nuxt projects found in the scanned repositories."
fi