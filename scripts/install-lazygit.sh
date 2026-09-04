#!/usr/bin/env bash

set -Eeuo pipefail

INSTALL_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"

if command -v lazygit >/dev/null 2>&1; then
    echo "lazygit is already installed."
    exit 0
fi

case "$(uname -m)" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $(uname -m)" >&2
        exit 1
        ;;
esac

echo "Installing lazygit..."

VERSION="$(
    curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep -Po '"tag_name":\s*"v\K[^"]+'
)"

[[ -n "$VERSION" ]] || {
    echo "Could not determine latest lazygit version." >&2
    exit 1
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL \
    "https://github.com/jesseduffield/lazygit/releases/download/v${VERSION}/lazygit_${VERSION}_Linux_${ARCH}.tar.gz" \
    -o "$TMP_DIR/lazygit.tar.gz"

tar -xzf "$TMP_DIR/lazygit.tar.gz" \
    -C "$TMP_DIR" \
    lazygit

install -m 0755 \
    "$TMP_DIR/lazygit" \
    "$INSTALL_DIR/lazygit"

echo "lazygit $VERSION installed."
