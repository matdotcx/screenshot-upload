#!/bin/bash

# Screenshot Upload Installer
# Installs the screenshot upload script and launchd agent

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
SCREENSHOT_DIR="$HOME/Documents/Screenshots"
PROCESSED_DIR="$HOME/Documents/Screenshots/Processed"
PLIST_NAME="org.iaconelli.screenshot-upload.plist"

echo "Screenshot Upload Installer"
echo "============================"
echo ""

# Create directories
echo "[1/5] Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$LAUNCHAGENT_DIR"
mkdir -p "$SCREENSHOT_DIR"
mkdir -p "$PROCESSED_DIR"

# Install script
echo "[2/5] Installing script to $INSTALL_DIR..."
cp "$SCRIPT_DIR/upload-screenshot.sh" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/upload-screenshot.sh"

# Install plist with home directory substitution
echo "[3/5] Installing launchd agent..."
sed "s|__HOME__|$HOME|g" "$SCRIPT_DIR/launchd/$PLIST_NAME" > "$LAUNCHAGENT_DIR/$PLIST_NAME"

# Unload existing agent if present
echo "[4/5] Loading launchd agent..."
launchctl unload "$LAUNCHAGENT_DIR/$PLIST_NAME" 2>/dev/null || true
launchctl load "$LAUNCHAGENT_DIR/$PLIST_NAME"

# Verify
echo "[5/5] Verifying installation..."
if launchctl list | grep -q "org.iaconelli.screenshot-upload"; then
    echo ""
    echo "Installation complete!"
    echo ""
    echo "Summary:"
    echo "  - Script installed to: $INSTALL_DIR/upload-screenshot.sh"
    echo "  - LaunchAgent installed to: $LAUNCHAGENT_DIR/$PLIST_NAME"
    echo "  - Watching folder: $SCREENSHOT_DIR"
    echo "  - Processed files: $PROCESSED_DIR"
    echo "  - Logs: ~/Library/Logs/screenshot-upload.log"
    echo ""
    echo "To test: save a screenshot to $SCREENSHOT_DIR"
else
    echo ""
    echo "ERROR: LaunchAgent failed to load. Check:"
    echo "  tail -f ~/Library/Logs/screenshot-upload-launchd.log"
    exit 1
fi
