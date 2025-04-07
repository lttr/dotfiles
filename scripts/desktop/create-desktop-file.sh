#!/bin/bash

# Script to create a .desktop file for GNOME

# Make sure the applications directory exists
mkdir -p ~/.local/share/applications

# Prompt for application details
echo "Creating a new desktop entry for GNOME..."
echo "----------------------------------------"

read -p "Enter application name: " APP_NAME
read -p "Enter full path to executable: " EXEC_PATH
read -p "Enter full path to icon: " ICON_PATH

# Default to Utility if no category provided
if [ -z "$CATEGORIES" ]; then
    CATEGORIES="Utility;"
fi

# Create the desktop file
DESKTOP_FILE=~/.local/share/applications/${APP_NAME,,}.desktop

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$EXEC_PATH
Icon=$ICON_PATH
Type=Application
Categories=$CATEGORIES
EOF

# Make the .desktop file executable
chmod +x "$DESKTOP_FILE"

# Update the desktop database
update-desktop-database ~/.local/share/applications

echo "----------------------------------------"
echo "Desktop file created at: $DESKTOP_FILE"
echo "The application should now appear in your GNOME menu."
echo "If it doesn't show up immediately, you might need to log out and log back in."
