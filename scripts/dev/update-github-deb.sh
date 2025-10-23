#!/usr/bin/env bash

# Configuration
GITHUB_REPO="aaddrick/claude-desktop-debian"
DEB_PATTERN="*.deb"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling
set -e
trap 'echo -e "${RED}Error occurred. Exiting.${NC}" >&2' ERR

echo -e "${BLUE}Fetching latest release information for ${GITHUB_REPO}...${NC}"

# Fetch latest release info from GitHub API
RELEASE_INFO=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")

# Extract version and release date
VERSION=$(echo "$RELEASE_INFO" | jq -r '.tag_name')
RELEASE_DATE=$(echo "$RELEASE_INFO" | jq -r '.published_at' | cut -d'T' -f1)
RELEASE_NAME=$(echo "$RELEASE_INFO" | jq -r '.name')

# Find deb file URL
DEB_URL=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test(".*\\.deb$")) | .browser_download_url' | head -n1)
DEB_NAME=$(echo "$RELEASE_INFO" | jq -r '.assets[] | select(.name | test(".*\\.deb$")) | .name' | head -n1)

# Validate that we found a deb file
if [ -z "$DEB_URL" ] || [ "$DEB_URL" = "null" ]; then
    echo -e "${RED}No .deb file found in the latest release${NC}"
    exit 1
fi

# Display release information
echo ""
echo -e "${GREEN}Latest Release Found:${NC}"
echo -e "  Repository:    ${GITHUB_REPO}"
echo -e "  Version:       ${YELLOW}${VERSION}${NC}"
echo -e "  Release Name:  ${RELEASE_NAME}"
echo -e "  Release Date:  ${RELEASE_DATE}"
echo -e "  Package:       ${DEB_NAME}"
echo ""

# Ask for confirmation
read -p "Do you want to download and install this version? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo -e "${BLUE}Downloading ${DEB_NAME}...${NC}"
curl -L -o "$DEB_NAME" "$DEB_URL"

echo -e "${BLUE}Installing package...${NC}"
sudo dpkg -i "$DEB_NAME"

# Fix any dependency issues
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Fixing dependencies...${NC}"
    sudo apt-get install -f -y
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "Installed: ${YELLOW}${DEB_NAME}${NC} (${VERSION})"
