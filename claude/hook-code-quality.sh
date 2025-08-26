#!/bin/bash

# Claude Code Quality Hook
# Automatically runs ESLint, TypeScript checking, and Prettier on file changes
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

# Check if a config file exists
has_config() {
    local config_type="$1"
    local project_root="$2"
    
    case "$config_type" in
        "eslint")
            [[ -f "$project_root/eslint.config.js" ]] || [[ -f "$project_root/eslint.config.ts" ]] || [[ -f "$project_root/.eslintrc.js" ]] || [[ -f "$project_root/.eslintrc.json" ]]
            ;;
        "typescript")
            [[ -f "$project_root/tsconfig.json" ]]
            ;;
        "vue-tsc")
            # Check if vue-tsc is in package.json dependencies or if it's a Nuxt project
            if [[ -f "$project_root/package.json" ]]; then
                grep -q '"vue-tsc"' "$project_root/package.json" || \
                grep -q '"@nuxt/typescript-build"' "$project_root/package.json" || \
                [[ -f "$project_root/nuxt.config.js" ]] || [[ -f "$project_root/nuxt.config.ts" ]]
            else
                false
            fi
            ;;
        "prettier")
            [[ -f "$project_root/.prettierrc" ]] || [[ -f "$project_root/.prettierrc.json" ]] || \
            [[ -f "$project_root/.prettierrc.js" ]] || [[ -f "$project_root/.prettierrc.yaml" ]] || \
            [[ -f "$project_root/.prettierrc.yml" ]] || [[ -f "$project_root/prettier.config.js" ]] || \
            ([ -f "$project_root/package.json" ] && grep -q '"prettier"' "$project_root/package.json")
            ;;
    esac
}

# Check if file matches extension pattern
matches_extension() {
    local file="$1"
    local pattern="$2"
    
    case "$pattern" in
        "eslint")
            [[ "$file" =~ \.(mjs|js|cjs|ts|vue|svelte)$ ]]
            ;;
        "typescript")
            [[ "$file" =~ \.ts$ ]]
            ;;
        "vue-tsc")
            [[ "$file" =~ \.vue$ ]]
            ;;
        "prettier")
            [[ "$file" =~ \.(js|jsx|ts|tsx|vue|svelte|json|css|scss|less|html|md|yaml|yml)$ ]]
            ;;
    esac
}

# Execute tool on single file
run_tool() {
    local tool="$1"
    local project_root="$2"
    local file="$3"
    
    if [[ -z "$file" ]] || [[ ! -f "$file" ]]; then
        return 0
    fi
    
    log "Running $tool on $file in $project_root"
    
    cd "$project_root" 2>/dev/null || return 1
    
    case "$tool" in
        "eslint")
            if command -v pnpm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
                pnpm exec eslint --fix "$file" 2>/dev/null || true
            elif command -v npx >/dev/null 2>&1; then
                npx eslint --fix "$file" 2>/dev/null || true
            fi
            ;;
        "typescript")
            if command -v pnpm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
                pnpm exec tsc --noEmit 2>/dev/null || true
            elif command -v npx >/dev/null 2>&1; then
                npx tsc --noEmit 2>/dev/null || true
            fi
            ;;
        "vue-tsc")
            if command -v pnpm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
                pnpm exec vue-tsc --noEmit 2>/dev/null || true
            elif command -v npx >/dev/null 2>&1; then
                npx vue-tsc --noEmit 2>/dev/null || true
            fi
            ;;
        "prettier")
            if command -v pnpm >/dev/null 2>&1 && [[ -f "package.json" ]]; then
                pnpm exec prettier --write "$file" 2>/dev/null || true
            elif command -v npx >/dev/null 2>&1; then
                npx prettier --write "$file" 2>/dev/null || true
            fi
            ;;
    esac
}

# Process single file with all applicable tools
process_file() {
    local file="$1"
    local project_root="$2"
    
    if [[ -z "$file" ]] || [[ ! -f "$file" ]]; then
        return 0
    fi
    
    log "Processing file: $file in project: $project_root"
    
    # Convert to absolute path if relative
    if [[ ! "$file" = /* ]]; then
        file="$project_root/$file"
    fi
    
    # Run tools in order: ESLint -> TypeScript -> Prettier
    if has_config "eslint" "$project_root" && matches_extension "$file" "eslint"; then
        run_tool "eslint" "$project_root" "$file"
    fi
    
    if has_config "typescript" "$project_root" && matches_extension "$file" "typescript"; then
        run_tool "typescript" "$project_root" "$file"
    fi
    
    if has_config "vue-tsc" "$project_root" && matches_extension "$file" "vue-tsc"; then
        run_tool "vue-tsc" "$project_root" "$file"
    fi
    
    if has_config "prettier" "$project_root" && matches_extension "$file" "prettier"; then
        run_tool "prettier" "$project_root" "$file"
    fi
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
            if [[ -n "$file" ]]; then
                process_file "$file" "$project_root"
                ((file_count++))
            fi
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
