#!/bin/bash

# Script to identify package type, installation date, version, and executable path for a given command
# Usage: package-info.sh <command_name>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command_name>"
    exit 1
fi

COMMAND="$1"
EXECUTABLE_PATH=""

# Check what type of command this is first
COMMAND_TYPE=$(type -t "$COMMAND" 2>/dev/null)

case "$COMMAND_TYPE" in
    "alias")
        ALIAS_DEF=$(alias "$COMMAND" 2>/dev/null | sed "s/^alias $COMMAND='//; s/'$//" )
        echo "shell-alias | target: $ALIAS_DEF | installed: built-in"
        echo "alias definition"
        exit 0
        ;;
    "function")
        echo "shell-function | version: user-defined | installed: session"
        echo "function definition"
        exit 0
        ;;
    "builtin")
        echo "shell-builtin | version: shell-internal | installed: built-in"
        echo "shell builtin"
        exit 0
        ;;
    "keyword")
        echo "shell-keyword | version: language-construct | installed: built-in"
        echo "shell keyword"
        exit 0
        ;;
    "file"|"")
        # Continue with executable detection
        ;;
esac

# Find the executable path
if command -v "$COMMAND" >/dev/null 2>&1; then
    EXECUTABLE_PATH=$(which "$COMMAND" 2>/dev/null || command -v "$COMMAND")
else
    echo "Command '$COMMAND' not found"
    echo ""
    exit 1
fi

# Function to get package info from different sources
get_package_info() {
    local cmd="$1"
    local exec_path="$2"
    
    # Check if it's a snap package
    if snap list "$cmd" >/dev/null 2>&1; then
        local snap_info=$(snap list "$cmd" 2>/dev/null | tail -n +2)
        local version=$(echo "$snap_info" | awk '{print $2}')
        local install_date=$(snap changes | grep "Install \"$cmd\"" | head -1 | awk '{print $1}' | xargs -I{} snap change {} | grep "^2" | head -1 | awk '{print $1" "$2}')
        echo "snap | version: $version | installed: ${install_date:-unknown}"
        return 0
    fi
    
    # Check if it's a flatpak
    if flatpak list --app | grep -q "$cmd" 2>/dev/null; then
        local flatpak_info=$(flatpak list --app | grep "$cmd")
        local version=$(echo "$flatpak_info" | awk -F'\t' '{print $3}')
        echo "flatpak | version: ${version:-unknown} | installed: unknown"
        return 0
    fi
    
    # Check if it's installed via apt/dpkg
    local deb_package=$(dpkg -S "$exec_path" 2>/dev/null | cut -d: -f1 | head -1)
    if [ -n "$deb_package" ]; then
        local version=$(dpkg -l "$deb_package" 2>/dev/null | tail -1 | awk '{print $3}')
        local install_date=$(stat -c %y /var/lib/dpkg/info/"$deb_package".list 2>/dev/null | cut -d' ' -f1)
        
        # Check if it's a manually installed deb
        if [ -f "/var/log/dpkg.log" ]; then
            local manual_install=$(grep "install $deb_package" /var/log/dpkg.log 2>/dev/null | tail -1 | awk '{print $1" "$2}')
            if [ -n "$manual_install" ]; then
                echo "deb-package | version: $version | installed: $manual_install"
                return 0
            fi
        fi
        
        echo "apt-install | version: $version | installed: ${install_date:-unknown}"
        return 0
    fi
    
    # Check if it's a brew package
    if command -v brew >/dev/null 2>&1; then
        local brew_prefix=$(brew --prefix 2>/dev/null)
        if [[ "$exec_path" == "$brew_prefix"* ]]; then
            # First try exact formula name match
            local formula=$(brew list --formula | grep -E "(^|/)$cmd$" | head -1)
            
            # If no exact match, find which formula provides this executable
            if [ -z "$formula" ]; then
                formula=$(brew --prefix)/bin/$cmd
                if [ -L "$formula" ]; then
                    # Follow symlink to find the actual formula
                    local target=$(readlink "$formula")
                    if [[ "$target" == *"../Cellar/"* ]]; then
                        formula=$(echo "$target" | sed 's|.*../Cellar/||; s|/.*||')
                    fi
                elif [ -f "$exec_path" ]; then
                    # Try to determine formula from path structure
                    formula=$(echo "$exec_path" | sed "s|$brew_prefix/Cellar/||; s|/.*||")
                fi
            fi
            
            if [ -n "$formula" ] && brew list --versions "$formula" >/dev/null 2>&1; then
                local version=$(brew list --versions "$formula" 2>/dev/null | awk '{print $2}')
                local install_date=$(stat -c %y "$brew_prefix/Cellar/$formula" 2>/dev/null | cut -d' ' -f1)
                echo "brew | version: $version | installed: ${install_date:-unknown}"
                return 0
            fi
        fi
    fi
    
    # Check if it's a pnpm global package
    if command -v pnpm >/dev/null 2>&1; then
        local pnpm_global_dir=$(pnpm config get global-dir 2>/dev/null)
        if [[ "$exec_path" == "$pnpm_global_dir"* ]] || [[ "$exec_path" == *"pnpm/global"* ]]; then
            local package_info=$(pnpm list -g --depth=0 2>/dev/null | grep "$cmd" | head -1)
            if [ -n "$package_info" ]; then
                local version=$(echo "$package_info" | sed -n 's/.*@\([^[:space:]]*\).*/\1/p')
                local install_date=$(stat -c %y "$exec_path" 2>/dev/null | cut -d' ' -f1)
                echo "pnpm | version: ${version:-unknown} | installed: ${install_date:-unknown}"
                return 0
            fi
        fi
    fi
    
    # Check if it's an npm global package
    if command -v npm >/dev/null 2>&1; then
        local npm_global_dir=$(npm config get prefix 2>/dev/null)
        if [[ "$exec_path" == "$npm_global_dir"* ]]; then
            local package_info=$(npm list -g --depth=0 2>/dev/null | grep "$cmd" | head -1)
            if [ -n "$package_info" ]; then
                local version=$(echo "$package_info" | sed -n 's/.*@\([^[:space:]]*\).*/\1/p')
                local install_date=$(stat -c %y "$exec_path" 2>/dev/null | cut -d' ' -f1)
                echo "npm | version: ${version:-unknown} | installed: ${install_date:-unknown}"
                return 0
            fi
        fi
    fi
    
    # Check if it's in user local directories (likely shell-script)
    if [[ "$exec_path" == "$HOME/.local"* ]] || [[ "$exec_path" == "$HOME/bin"* ]] || [[ "$exec_path" == "$HOME/opt"* ]]; then
        local install_date=$(stat -c %y "$exec_path" 2>/dev/null | cut -d' ' -f1)
        local version="unknown"
        
        # Try to get version from the executable itself
        if [ -x "$exec_path" ]; then
            version=$("$exec_path" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            [ -z "$version" ] && version=$("$exec_path" -V 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            [ -z "$version" ] && version="unknown"
        fi
        
        echo "shell-script | version: $version | installed: ${install_date:-unknown}"
        return 0
    fi
    
    # Check if it's a system binary
    if [[ "$exec_path" == "/usr/bin"* ]] || [[ "$exec_path" == "/bin"* ]] || [[ "$exec_path" == "/usr/local/bin"* ]]; then
        local version="unknown"
        if [ -x "$exec_path" ]; then
            version=$("$exec_path" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            [ -z "$version" ] && version=$("$exec_path" -V 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            [ -z "$version" ] && version="system"
        fi
        echo "system | version: $version | installed: unknown"
        return 0
    fi
    
    # Default fallback
    local install_date=$(stat -c %y "$exec_path" 2>/dev/null | cut -d' ' -f1)
    echo "unknown | version: unknown | installed: ${install_date:-unknown}"
}

# Get package information
get_package_info "$COMMAND" "$EXECUTABLE_PATH"
echo "$EXECUTABLE_PATH"