#!/bin/bash

# ==========================================
# Script: create_users.sh
# Description:
# Creates users from arguments,
# creates folders in home directory,
# sets permissions,
# and generates a welcome file.
# ==========================================

# ------------------------------------------
# Check if script is run as root
# UID 0 = root
# ------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# ------------------------------------------
# Check if at least one username is provided
# ------------------------------------------
if [ $# -eq 0 ]; then
    echo "Usage: $0 username1 username2 ..."
    exit 1
fi

# ------------------------------------------
# Loop through all usernames
# ------------------------------------------
for USERNAME in "$@"
do
    # Check if user already exists
    if id "$USERNAME" &>/dev/null; then
        echo "User $USERNAME already exists. Skipping..."
        continue
    fi

    echo "Creating user: $USERNAME"

    # Create user with home directory
    useradd -m "$USERNAME"

    # Set home directory path
    HOME_DIR="/home/$USERNAME"

    # --------------------------------------
    # Create directories
    # --------------------------------------
    mkdir -p "$HOME_DIR/Documents"
    mkdir -p "$HOME_DIR/Downloads"
    mkdir -p "$HOME_DIR/Work"

    # --------------------------------------
    # Set ownership
    # --------------------------------------
    chown -R "$USERNAME:$USERNAME" "$HOME_DIR"

    # --------------------------------------
    # Set permissions
    # 700 = owner can read/write/execute only
    # --------------------------------------
    chmod 700 "$HOME_DIR/Documents"
    chmod 700 "$HOME_DIR/Downloads"
    chmod 700 "$HOME_DIR/Work"

    # --------------------------------------
    # Create welcome.txt
    # --------------------------------------
    WELCOME_FILE="$HOME_DIR/welcome.txt"

    echo "Välkommen $USERNAME" > "$WELCOME_FILE"
    echo "" >> "$WELCOME_FILE"
    echo "Andra användare i systemet:" >> "$WELCOME_FILE"

    # List all users from /etc/passwd
    cut -d: -f1 /etc/passwd >> "$WELCOME_FILE"

    # Set correct ownership and permissions
    chown "$USERNAME:$USERNAME" "$WELCOME_FILE"
    chmod 600 "$WELCOME_FILE"

    echo "User $USERNAME created successfully."
done

echo "All tasks completed."
