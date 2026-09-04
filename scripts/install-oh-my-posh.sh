#!/usr/bin/env bash

set -Eeuo pipefail

INSTALL_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"

if command -v oh-my-posh >/dev/null 2>&1; then
    echo "Oh My Posh is already installed."
else
    echo "Installing Oh My Posh..."

    curl -fsSL https://ohmyposh.dev/install.sh |
        bash -s -- -d "$INSTALL_DIR"
fi

if ! command -v oh-my-posh >/dev/null 2>&1 \
    && [[ ! -x "$INSTALL_DIR/oh-my-posh" ]]; then
    echo "Oh My Posh installation failed." >&2
    exit 1
fi

echo "Oh My Posh installed."
