#!/bin/bash

# Claude Code Format Hook
# Automatically runs Prettier formatting on file changes
# 
# Prerequisites:
#   - pnpm (package manager)
# 
# Usage:
#   Hook mode: ./format-code.sh /path/to/file
#   Standalone mode: ./format-code.sh

set -e

# Configuration
LOG_FILE="/tmp/claude-hook-format-code.log"

# Logging function
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Find project root by looking for package.json or .git
find_project_root() {
    local dir="$1"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/package.json" ]] || [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "$PWD"  # fallback to current directory
}

# Tool configuration and extensions
declare -A TOOL_CONFIGS=(
    [prettier]=".prettierrc .prettierrc.json .prettierrc.js .prettierrc.yaml .prettierrc.yml prettier.config.js"
)

declare -A TOOL_EXTENSIONS=(
    [prettier]="js jsx ts tsx vue svelte json css scss less html md yaml yml"
)

declare -A TOOL_COMMANDS=(
    [prettier]="pnpm exec prettier --write"
)

# Check if Prettier config exists
has_prettier_config() {
    local project_root="$1"
    # Check for config files
    for config in ${TOOL_CONFIGS[prettier]}; do
        [[ -f "$project_root/$config" ]] && return 0
    done
    # Check package.json
    if [[ -f "$project_root/package.json" ]]; then
        grep -q '"prettier"' "$project_root/package.json" && return 0
    fi
    return 1
}

# Check if file matches extension pattern
matches_extension() {
    local file="$1"
    local tool="$2"
    local ext="${file##*.}"
    
    # Check if extension exists in the tool's supported extensions by pattern matching
    [[ " ${TOOL_EXTENSIONS[$tool]} " == *" $ext "* ]]
}

# Execute tool on single file
run_tool() {
    local tool="$1"
    local project_root="$2"
    local file="$3"
    local filename=$(basename "$file")
    
    log "run_tool called with: tool=$tool, project_root=$project_root, file=$file"
    
    if ! cd "$project_root" 2>/dev/null; then
        log "Failed to cd to project root: $project_root"
        return 1
    fi
    
    log "Successfully changed to project root: $project_root"
    log "Current directory after cd: $(pwd)"
    
    case "$tool" in
        "prettier") echo "Prettier formatting: $filename" ;;
    esac
    
    log "About to run command: ${TOOL_COMMANDS[$tool]} $file"
    
    # Run the command and capture both stdout and stderr
    local cmd_output
    local cmd_exit_code
    cmd_output=$(${TOOL_COMMANDS[$tool]} "$file" 2>&1)
    cmd_exit_code=$?
    
    log "Command output: $cmd_output"
    log "Command exit code: $cmd_exit_code"
    
    if [[ $cmd_exit_code -ne 0 ]]; then
        log "Command failed with exit code $cmd_exit_code"
        echo "Error running $tool: $cmd_output" >&2
    fi
    
    return 0  # Always return 0 to not fail the hook
}

# Process single file with all applicable tools
process_file() {
    local file="$1"
    local project_root="$2"
    
    local filename=$(basename "$file")
    log "Processing file: $file in project: $project_root"
    
    # Convert to absolute path if relative
    if [[ ! "$file" = /* ]]; then
        file="$project_root/$file"
    fi
    
    # Run Prettier formatting
    local tools_applied=0
    
    if has_prettier_config "$project_root" && matches_extension "$file" "prettier"; then
        run_tool "prettier" "$project_root" "$file"
        ((tools_applied++))
    fi
    
    # Log if no tools were applicable
    if [[ $tools_applied -eq 0 ]]; then
        log "No applicable tools found for $file"
    fi
    
    return 0
}

# Standalone mode: process all git changes
standalone_mode() {
    log "Running in standalone mode"
    
    local project_root
    project_root=$(find_project_root "$PWD")
    
    # Get all changed and new files from git
    if [[ -d ".git" ]] || git rev-parse --git-dir > /dev/null 2>&1; then
        # Get modified, added, and untracked files
        local file_count=0
        while IFS= read -r file; do
            [[ -n "$file" && -f "$file" ]] && {
                process_file "$file" "$project_root"
                ((file_count++))
            }
        done < <(git status --porcelain | awk '{print $2}' | grep -v '^$')
        
        if [[ $file_count -eq 0 ]]; then
            log "No changed files found"
        fi
    else
        log "Not a git repository, skipping standalone mode"
        return 0
    fi
}

# Hook mode: process single file
hook_mode() {
    local file_path="$1"
    
    log "hook_mode called with file_path: $file_path"
    
    if [[ -z "$file_path" ]]; then
        log "Empty file path provided"
        return 1
    fi
    
    if [[ ! -f "$file_path" ]]; then
        log "File does not exist: $file_path"
        log "ls -la dirname: $(ls -la "$(dirname "$file_path")" 2>&1 || echo 'failed')"
        return 1
    fi
    
    log "File exists: $file_path"
    log "File info: $(ls -la "$file_path")"
    
    local project_root
    project_root=$(find_project_root "$(dirname "$file_path")")
    log "Found project root: $project_root"
    
    # Process the file immediately
    log "About to process file: $file_path in project: $project_root"
    process_file "$file_path" "$project_root"
    local process_exit_code=$?
    log "process_file returned: $process_exit_code"
    
    return $process_exit_code
}

# Main execution
main() {
    # Initialize log
    log "Hook started with args: $*"
    log "PWD: $PWD"
    log "Number of args: $#"
    
    # Log environment info
    log "PATH: $PATH"
    log "which pnpm: $(which pnpm 2>&1 || echo 'not found')"
    log "pnpm --version: $(pnpm --version 2>&1 || echo 'failed')"
    
    if [[ $# -eq 0 ]]; then
        # No arguments: standalone mode
        log "Running in standalone mode"
        standalone_mode
        local exit_code=$?
        log "Standalone mode exit code: $exit_code"
        exit $exit_code
    else
        # File path provided: hook mode
        log "Running in hook mode with file: $1"
        hook_mode "$1"
        local exit_code=$?
        log "Hook mode exit code: $exit_code"
        exit $exit_code
    fi
}

# Run main function
main "$@"