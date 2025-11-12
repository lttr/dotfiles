#!/bin/bash

set -e

# Check if running in a Nuxt project
if [ ! -f "nuxt.config.ts" ]; then
    echo "Error: nuxt.config.ts not found."
    echo "This script must be run from the root of a Nuxt project."
    exit 1
fi

# Function to prompt for confirmation
confirm() {
    local prompt="$1"
    local response
    
    while true; do
        read -p "$prompt (y/n): " response
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to safely create/overwrite a file
safe_write_file() {
    local filepath="$1"
    local content="$2"
    
    if [ -f "$filepath" ]; then
        echo "File '$filepath' already exists."
        if confirm "Overwrite it?"; then
            echo "$content" > "$filepath"
            echo "Overwrote $filepath"
        else
            echo "Skipped $filepath"
            return 1
        fi
    else
        echo "$content" > "$filepath"
        echo "Created $filepath"
    fi
    return 0
}

echo "Setup verification, linting, and formatting tools"
echo

# Add ESLint dependencies
echo "Installing ESLint dependencies..."
pnpm add -D eslint @nuxt/eslint @lttr/nuxt-config-eslint

echo
echo "Creating configuration files..."
echo

# Create ESLint config
ESLINT_CONFIG='import withNuxt from "./.nuxt/eslint.config.mjs"
import customConfig from "@lttr/nuxt-config-eslint"

export default withNuxt(customConfig)'

safe_write_file "eslint.config.js" "$ESLINT_CONFIG"

# Create Prettier ignore
safe_write_file ".prettierignore" "pnpm-lock.yaml"

# Create Prettier config
PRETTIER_CONFIG='{
  "semi": false
}'

safe_write_file ".prettierrc" "$PRETTIER_CONFIG"

echo
echo "Adding npm scripts..."
echo

# Add npm scripts (warn if already exists)
pnpm dlx add-npm-scripts --warn 'verify' 'npm run format && npm run lint:fix && npm run typecheck && npm test'
pnpm dlx add-npm-scripts --warn 'test' 'exit 0'
pnpm dlx add-npm-scripts --warn 'format' 'prettier --list-different --write . --'
pnpm dlx add-npm-scripts --warn 'lint' 'eslint'
pnpm dlx add-npm-scripts --warn 'lint:fix' 'eslint --fix'
pnpm dlx add-npm-scripts --warn 'typecheck' 'nuxt typecheck'

echo
if confirm "Format package.json?"; then
    pnpm dlx format-package --write
    echo "Formatted package.json"
else
    echo "Skipped formatting package.json"
fi

echo
echo "Setup complete!"

