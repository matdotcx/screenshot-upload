#!/bin/bash

# Screenshot Upload Uninstaller
# Removes the screenshot upload script and launchd agent

INSTALL_DIR="$HOME/.local/bin"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_NAME="org.iaconelli.screenshot-upload.plist"

echo "Screenshot Upload Uninstaller"
echo "=============================="
echo ""

# Unload agent
echo "[1/3] Unloading launchd agent..."
launchctl unload "$LAUNCHAGENT_DIR/$PLIST_NAME" 2>/dev/null || true

# Remove files
echo "[2/3] Removing files..."
rm -f "$LAUNCHAGENT_DIR/$PLIST_NAME"
rm -f "$INSTALL_DIR/upload-screenshot.sh"

echo "[3/3] Done."
echo ""
echo "Uninstallation complete."
echo ""
echo "Note: Screenshot folders and logs have been left in place."
echo "Remove manually if desired:"
echo "  rm -rf ~/Documents/Screenshots"
echo "  rm -f ~/Library/Logs/screenshot-upload*.log"
