#!/bin/bash

# Claude Code Quality Hook
# Automatically runs ESLint, TypeScript checking, and Prettier on file changes
# 
# Prerequisites:
#   - pnpm (package manager)
# 
# Usage:
#   Hook mode: ./hook-code-quality.sh /path/to/file
#   Standalone mode: ./hook-code-quality.sh

set -e

# Configuration
LOG_FILE="/tmp/claude-hook-code-quality.log"

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
    [eslint]="eslint.config.js eslint.config.ts .eslintrc.js .eslintrc.json"
    [typescript]="tsconfig.json"
    [vue-tsc]="nuxt.config.js nuxt.config.ts"
    [prettier]=".prettierrc .prettierrc.json .prettierrc.js .prettierrc.yaml .prettierrc.yml prettier.config.js"
)

declare -A TOOL_EXTENSIONS=(
    [eslint]="mjs js cjs ts vue svelte"
    [typescript]="ts"
    [vue-tsc]="vue"
    [prettier]="js jsx ts tsx vue svelte json css scss less html md yaml yml"
)

declare -A TOOL_COMMANDS=(
    [eslint]="pnpm exec eslint --fix"
    [typescript]="pnpm exec tsc --noEmit"
    [vue-tsc]="pnpm exec vue-tsc --noEmit"
    [prettier]="pnpm exec prettier --write"
)

# Check if a config file exists
has_config() {
    local tool="$1"
    local project_root="$2"
    
    # Special case for vue-tsc: check package.json dependencies too
    if [[ "$tool" == "vue-tsc" ]]; then
        [[ -f "$project_root/package.json" ]] && {
            grep -q '"vue-tsc"\|"@nuxt/typescript-build"' "$project_root/package.json" ||
            [[ -f "$project_root/nuxt.config.js" ]] || [[ -f "$project_root/nuxt.config.ts" ]]
        }
        return $?
    fi
    
    # Check for config files
    for config in ${TOOL_CONFIGS[$tool]}; do
        [[ -f "$project_root/$config" ]] && return 0
    done
    
    # Special case for prettier: check package.json
    if [[ "$tool" == "prettier" && -f "$project_root/package.json" ]]; then
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
    
    cd "$project_root" 2>/dev/null || return 1
    
    # Add spacing for non-eslint tools
    [[ "$tool" != "eslint" ]] && echo
    
    case "$tool" in
        "eslint") echo "ESLint fixing: $filename" ;;
        "typescript") echo "TypeScript checking: $filename" ;;
        "vue-tsc") echo "Vue TypeScript checking: $filename" ;;
        "prettier") echo "Prettier formatting: $filename" ;;
    esac
    
    log "Running ${tool} on $file"
    ${TOOL_COMMANDS[$tool]} "$file" 2>/dev/null || true
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
    
    # Run tools in order: ESLint -> TypeScript -> Vue TypeScript -> Prettier
    local tools_applied=0
    for tool in eslint typescript vue-tsc prettier; do
        if has_config "$tool" "$project_root" && matches_extension "$file" "$tool"; then
            run_tool "$tool" "$project_root" "$file"
            ((tools_applied++))
        fi
    done
    
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
    
    if [[ -z "$file_path" ]] || [[ ! -f "$file_path" ]]; then
        log "Invalid file path: $file_path"
        return 1
    fi
    
    local project_root
    project_root=$(find_project_root "$(dirname "$file_path")")
    
    # Process the file immediately
    process_file "$file_path" "$project_root"
}

# Main execution
main() {
    # Initialize log
    log "Hook started with args: $*"
    
    if [[ $# -eq 0 ]]; then
        # No arguments: standalone mode
        standalone_mode
    else
        # File path provided: hook mode
        hook_mode "$1"
    fi
}

# Run main function
main "$@"
