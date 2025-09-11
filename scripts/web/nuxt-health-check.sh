#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

print_status() {
    local status=$1
    local message=$2
    case $status in
        "ok") echo -e "${GREEN}✓${NC} $message" ;;
        "warn") echo -e "${YELLOW}⚠${NC} $message"; ISSUES_FOUND=$((ISSUES_FOUND + 1)) ;;
        "error") echo -e "${RED}✗${NC} $message"; ISSUES_FOUND=$((ISSUES_FOUND + 1)) ;;
        "info") echo -e "${BLUE}ℹ${NC} $message" ;;
    esac
}

check_package_json() {
    local dir=$1
    if [ ! -f "$dir/package.json" ]; then
        print_status "error" "Missing package.json"
        return 1
    fi
    print_status "ok" "package.json exists"
}

check_nuxt_project() {
    local dir=$1
    local project_name=$(basename "$dir")
    
    echo -e "\n${BLUE}=== Checking $project_name ===${NC}"
    
    if [ ! -f "$dir/package.json" ]; then
        print_status "error" "Not a Node.js project (missing package.json)"
        return
    fi
    
    # Check if it's a Nuxt project
    if ! grep -q "nuxt" "$dir/package.json" 2>/dev/null; then
        print_status "info" "Not a Nuxt project, skipping"
        return
    fi
    
    cd "$dir"
    
    # Check required files from setup script
    print_status "info" "Checking project structure..."
    
    [ -f "nuxt.config.ts" ] && print_status "ok" "nuxt.config.ts exists" || print_status "error" "Missing nuxt.config.ts"
    [ -f "eslint.config.js" ] && print_status "ok" "eslint.config.js exists" || print_status "warn" "Missing eslint.config.js"
    [ -f ".prettierrc" ] && print_status "ok" ".prettierrc exists" || print_status "warn" "Missing .prettierrc"
    [ -f "reset.d.ts" ] && print_status "ok" "reset.d.ts exists" || print_status "warn" "Missing reset.d.ts"
    [ -f ".node-version" ] && print_status "ok" ".node-version exists" || print_status "warn" "Missing .node-version"
    [ -f ".npmrc" ] && print_status "ok" ".npmrc exists" || print_status "warn" "Missing .npmrc"
    [ -d "app" ] && print_status "ok" "app directory exists" || print_status "error" "Missing app directory"
    [ -f "app/app.vue" ] && print_status "ok" "app/app.vue exists" || print_status "error" "Missing app/app.vue"
    [ -f "app/assets/css/main.css" ] && print_status "ok" "main.css exists" || print_status "warn" "Missing app/assets/css/main.css"
    [ -f "public/_robots.txt" ] && print_status "ok" "_robots.txt exists" || print_status "warn" "Missing public/_robots.txt"
    
    # Check for license and readme
    if [ -f "LICENSE" ] || [ -f "LICENSE.txt" ] || [ -f "LICENSE.md" ]; then
        print_status "ok" "License file exists"
    else
        print_status "warn" "Missing license file"
    fi
    
    if [ -f "README.md" ] || [ -f "readme.md" ] || [ -f "README.txt" ]; then
        print_status "ok" "README file exists"
    else
        print_status "warn" "Missing README file"
    fi
    
    # Check package.json scripts from setup
    print_status "info" "Checking package.json scripts..."
    
    local required_scripts=("format" "lint" "lint:fix" "typecheck" "test" "start" "verify")
    for script in "${required_scripts[@]}"; do
        if grep -q "\"$script\":" package.json; then
            print_status "ok" "Script '$script' exists"
        else
            print_status "warn" "Missing script '$script'"
        fi
    done
    
    # Check packageManager field
    if grep -q "\"packageManager\":" package.json; then
        print_status "ok" "packageManager field set"
    else
        print_status "warn" "Missing packageManager field in package.json"
    fi
    
    # Check Node version
    print_status "info" "Checking versions..."
    
    if [ -f ".node-version" ]; then
        local configured_node=$(cat .node-version)
        local latest_lts=$(curl -s https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)] | .[0].version' 2>/dev/null || echo "unknown")
        if [ "$latest_lts" != "unknown" ]; then
            local configured_major=$(echo $configured_node | sed 's/v//g' | cut -d. -f1)
            local latest_major=$(echo $latest_lts | sed 's/v//g' | cut -d. -f1)
            if [ "$configured_major" -ge "$latest_major" ]; then
                print_status "ok" "Node version: $configured_node (latest LTS: $latest_lts)"
            else
                print_status "warn" "Node version outdated: $configured_node (latest LTS: $latest_lts)"
            fi
        else
            print_status "ok" "Node version: $configured_node (unable to check latest)"
        fi
    fi
    
    # Check pnpm version
    if grep -q "packageManager.*pnpm" package.json 2>/dev/null; then
        local configured_pnpm=$(grep "packageManager.*pnpm" package.json | sed 's/.*pnpm@//g' | sed 's/".*//g')
        local latest_pnpm=$(npm view pnpm version 2>/dev/null || echo "unknown")
        if [ "$latest_pnpm" != "unknown" ]; then
            local configured_major=$(echo $configured_pnpm | cut -d. -f1)
            local configured_minor=$(echo $configured_pnpm | cut -d. -f2)
            local latest_major=$(echo $latest_pnpm | cut -d. -f1)
            local latest_minor=$(echo $latest_pnpm | cut -d. -f2)
            if [ "$configured_major" -gt "$latest_major" ] || ([ "$configured_major" -eq "$latest_major" ] && [ "$configured_minor" -ge "$latest_minor" ]); then
                print_status "ok" "pnpm version: $configured_pnpm (latest: $latest_pnpm)"
            else
                print_status "warn" "pnpm version outdated: $configured_pnpm (latest: $latest_pnpm)"
            fi
        else
            print_status "ok" "pnpm version: $configured_pnpm (unable to check latest)"
        fi
    fi
    
    # Check dependencies versions
    if [ -f "package.json" ]; then
        # Get installed versions
        local nuxt_version=$(node -p "require('./package.json').dependencies?.nuxt || require('./package.json').devDependencies?.nuxt || 'not found'" 2>/dev/null)
        local vue_version=$(node -p "require('./package.json').dependencies?.vue || require('./package.json').devDependencies?.vue || 'not found'" 2>/dev/null)
        local vue_router_version=$(node -p "require('./package.json').dependencies?.['vue-router'] || require('./package.json').devDependencies?.['vue-router'] || 'not found'" 2>/dev/null)
        
        # Check Nuxt version
        if [ "$nuxt_version" != "not found" ]; then
            local clean_nuxt_version=$(echo $nuxt_version | sed 's/[^0-9.]//g')
            local latest_nuxt=$(npm view nuxt version 2>/dev/null || echo "unknown")
            if [ "$latest_nuxt" != "unknown" ]; then
                local nuxt_major=$(echo $clean_nuxt_version | cut -d. -f1)
                local nuxt_minor=$(echo $clean_nuxt_version | cut -d. -f2)
                local latest_nuxt_major=$(echo $latest_nuxt | cut -d. -f1)
                local latest_nuxt_minor=$(echo $latest_nuxt | cut -d. -f2)
                if [ "$nuxt_major" -gt "$latest_nuxt_major" ] || ([ "$nuxt_major" -eq "$latest_nuxt_major" ] && [ "$nuxt_minor" -ge "$latest_nuxt_minor" ]); then
                    print_status "ok" "Nuxt version: $nuxt_version (latest: $latest_nuxt)"
                else
                    print_status "warn" "Nuxt version outdated: $nuxt_version (latest: $latest_nuxt)"
                fi
            else
                print_status "ok" "Nuxt version: $nuxt_version (unable to check latest)"
            fi
        else
            print_status "error" "Nuxt not found in dependencies"
        fi
        
        # Check Vue version
        if [ "$vue_version" != "not found" ]; then
            local clean_vue_version=$(echo $vue_version | sed 's/[^0-9.]//g')
            local latest_vue=$(npm view vue version 2>/dev/null || echo "unknown")
            if [ "$latest_vue" != "unknown" ]; then
                local vue_major=$(echo $clean_vue_version | cut -d. -f1)
                local vue_minor=$(echo $clean_vue_version | cut -d. -f2)
                local latest_vue_major=$(echo $latest_vue | cut -d. -f1)
                local latest_vue_minor=$(echo $latest_vue | cut -d. -f2)
                if [ "$vue_major" -gt "$latest_vue_major" ] || ([ "$vue_major" -eq "$latest_vue_major" ] && [ "$vue_minor" -ge "$latest_vue_minor" ]); then
                    print_status "ok" "Vue version: $vue_version (latest: $latest_vue)"
                else
                    print_status "warn" "Vue version outdated: $vue_version (latest: $latest_vue)"
                fi
            else
                print_status "ok" "Vue version: $vue_version (unable to check latest)"
            fi
        else
            print_status "warn" "Vue not found in dependencies"
        fi
        
        # Check Vue Router version
        if [ "$vue_router_version" != "not found" ]; then
            local clean_vue_router_version=$(echo $vue_router_version | sed 's/[^0-9.]//g')
            local latest_vue_router=$(npm view vue-router version 2>/dev/null || echo "unknown")
            if [ "$latest_vue_router" != "unknown" ]; then
                local vue_router_major=$(echo $clean_vue_router_version | cut -d. -f1)
                local vue_router_minor=$(echo $clean_vue_router_version | cut -d. -f2)
                local latest_vue_router_major=$(echo $latest_vue_router | cut -d. -f1)
                local latest_vue_router_minor=$(echo $latest_vue_router | cut -d. -f2)
                if [ "$vue_router_major" -gt "$latest_vue_router_major" ] || ([ "$vue_router_major" -eq "$latest_vue_router_major" ] && [ "$vue_router_minor" -ge "$latest_vue_router_minor" ]); then
                    print_status "ok" "Vue Router version: $vue_router_version (latest: $latest_vue_router)"
                else
                    print_status "warn" "Vue Router version outdated: $vue_router_version (latest: $latest_vue_router)"
                fi
            else
                print_status "ok" "Vue Router version: $vue_router_version (unable to check latest)"
            fi
        else
            print_status "info" "Vue Router not found in dependencies (may use Nuxt routing)"
        fi
        
        # Check for expected modules from setup script
        local expected_modules=("@nuxt/eslint" "@nuxt/fonts" "@nuxt/icon" "@nuxt/image" "@nuxtjs/seo" "@vueuse/nuxt")
        for module in "${expected_modules[@]}"; do
            if grep -q "\"$module\":" package.json; then
                print_status "ok" "Module '$module' installed"
            else
                print_status "warn" "Module '$module' missing"
            fi
        done
        
        # Check dev dependencies from setup
        local expected_dev_deps=("eslint" "prettier" "typescript" "@total-typescript/ts-reset" "vue-tsc")
        for dep in "${expected_dev_deps[@]}"; do
            if grep -q "\"$dep\":" package.json; then
                print_status "ok" "Dev dependency '$dep' installed"
            else
                print_status "warn" "Dev dependency '$dep' missing"
            fi
        done
    fi
    
    # Check if pnpm-lock.yaml exists (since setup uses pnpm)
    if [ -f "pnpm-lock.yaml" ]; then
        print_status "ok" "pnpm-lock.yaml exists"
    else
        print_status "warn" "Missing pnpm-lock.yaml (project might not use pnpm)"
    fi
    
    # Check if node_modules exists and is not empty
    if [ -d "node_modules" ] && [ "$(ls -A node_modules)" ]; then
        print_status "ok" "node_modules populated"
    else
        print_status "warn" "node_modules missing or empty - run 'pnpm install'"
    fi
    
    cd - > /dev/null
}

# Main execution
echo -e "${BLUE}Nuxt Health Check${NC}"
echo "Scanning for Nuxt projects..."

if [ $# -eq 0 ]; then
    # Check current directory and subdirectories
    SEARCH_DIR="."
else
    SEARCH_DIR="$1"
fi

# Find all directories with nuxt.config.ts
FOUND_PROJECTS=0
for dir in $(find "$SEARCH_DIR" -name "nuxt.config.ts" -type f -exec dirname {} \; | sort); do
    check_nuxt_project "$dir"
    FOUND_PROJECTS=$((FOUND_PROJECTS + 1))
done

echo -e "\n${BLUE}=== Summary ===${NC}"
echo "Projects checked: $FOUND_PROJECTS"

if [ $ISSUES_FOUND -eq 0 ]; then
    print_status "ok" "All checks passed!"
    exit 0
else
    print_status "warn" "$ISSUES_FOUND issue(s) found"
    exit 1
fi
