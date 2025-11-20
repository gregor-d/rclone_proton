#!/bin/bash

PERSISTENT_RCLONE_CONFIG="/volume1/config/rclone.conf"
DEFAULT_RCLONE_CONFIG="/root/.config/rclone/rclone.conf"

# Ensure directory exists
mkdir -p "$(dirname "$PERSISTENT_RCLONE_CONFIG")"
mkdir -p "$(dirname "$DEFAULT_RCLONE_CONFIG")"

# Install or update rclone
if ! command -v rclone &> /dev/null; then
    echo "rclone not found, installing..."
    curl https://rclone.org/install.sh | sudo bash
else
    echo "rclone found, checking for updates..."
    installed_version=$(rclone --version | head -1 | awk '{print $2}')
    latest_version=$(curl -s https://downloads.rclone.org/version.txt | awk '{print $2}')
    if [ "$installed_version" != "$latest_version" ]; then
        echo "Updating rclone from $installed_version to $latest_version"
        curl https://rclone.org/install.sh | sudo bash
    else
        echo "rclone is up to date."
    fi
fi

# Move config if it exists at default location
if [ -f "$DEFAULT_RCLONE_CONFIG" ] && [ ! -L "$DEFAULT_RCLONE_CONFIG" ]; then
    echo "Moving existing config to persistent location..."
    mv "$DEFAULT_RCLONE_CONFIG" "$PERSISTENT_RCLONE_CONFIG"
fi

# Create persistent config if missing
if [ ! -f "$PERSISTENT_RCLONE_CONFIG" ]; then
    echo "Creating new empty config at persistent location..."
    touch "$PERSISTENT_RCLONE_CONFIG"
fi

# Create/update symlink
if [ ! -L "$DEFAULT_RCLONE_CONFIG" ] || \
   [ "$(readlink -f "$DEFAULT_RCLONE_CONFIG")" != "$PERSISTENT_RCLONE_CONFIG" ]; then
    echo "Linking persistent config to default rclone path..."
    ln -sf "$PERSISTENT_RCLONE_CONFIG" "$DEFAULT_RCLONE_CONFIG"
else
    echo "Symlink already correct."
fi

echo "rclone persistent config setup complete."
