#!/usr/bin/env bash

set -Eeuo pipefail

INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="$INSTALL_DIR/ssh-pick"

SSH_PICK_URL="https://raw.githubusercontent.com/leonvsc/ssh-pick/main/ssh-pick"

mkdir -p "$INSTALL_DIR"

echo "Installing ssh-pick..."

curl -fsSL \
    "$SSH_PICK_URL" \
    -o "$INSTALL_PATH"

chmod +x "$INSTALL_PATH"

if [[ ! -x "$INSTALL_PATH" ]]; then
    echo "ssh-pick installation failed." >&2
    exit 1
fi

echo "ssh-pick installed to $INSTALL_PATH"
