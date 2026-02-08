#!/bin/bash
# Update iPXE menu from GitHub repository
# This script downloads the latest elfshoe.ipxe from GitHub and updates /tftpboot

set -euo pipefail

GITHUB_RAW_URL="https://raw.githubusercontent.com/timhughes/ipxe/main/docs/elfshoe.ipxe"
TFTPBOOT_DIR="/tftpboot"
TEMP_FILE="/tmp/elfshoe.ipxe.new"
TARGET_FILE="${TFTPBOOT_DIR}/elfshoe.ipxe"
LOG_TAG="update-ipxe-menu"

# Ensure tftpboot directory exists
if [ ! -d "$TFTPBOOT_DIR" ]; then
    logger -t "$LOG_TAG" "ERROR: Directory $TFTPBOOT_DIR does not exist"
    exit 1
fi

# Download latest menu from GitHub
if ! wget -q "$GITHUB_RAW_URL" -O "$TEMP_FILE"; then
    logger -t "$LOG_TAG" "ERROR: Failed to download from GitHub"
    exit 1
fi

# Validate downloaded file
if [ ! -s "$TEMP_FILE" ]; then
    logger -t "$LOG_TAG" "ERROR: Downloaded file is empty"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Check if file starts with #!ipxe (basic validation)
if ! head -n 1 "$TEMP_FILE" | grep -q '^#!ipxe'; then
    logger -t "$LOG_TAG" "ERROR: Downloaded file doesn't appear to be a valid iPXE script"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Only update if changed
if [ -f "$TARGET_FILE" ] && cmp -s "$TEMP_FILE" "$TARGET_FILE"; then
    rm -f "$TEMP_FILE"
    # Silent success - no change
    exit 0
fi

# Update the file
mv "$TEMP_FILE" "$TARGET_FILE"
chmod 644 "$TARGET_FILE"
chown root:root "$TARGET_FILE"

logger -t "$LOG_TAG" "Successfully updated elfshoe.ipxe from GitHub"
echo "$(date): Updated elfshoe.ipxe"
