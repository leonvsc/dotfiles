#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

THEME_NAME="sddm-astronaut-theme"
SOURCE_DIR="$REPO_ROOT/bootstrap/assets/sddm-themes/$THEME_NAME"
TARGET_DIR="/usr/share/sddm/themes/$THEME_NAME"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "SDDM theme source not found: $SOURCE_DIR"
  exit 1
fi

echo "Installing SDDM theme: $THEME_NAME"
sudo rm -rf "$TARGET_DIR"
sudo mkdir -p "$TARGET_DIR"
sudo cp -r "$SOURCE_DIR/." "$TARGET_DIR/"

echo "Configuring SDDM theme..."
sudo mkdir -p /etc/sddm.conf.d

sudo tee /etc/sddm.conf.d/theme.conf >/dev/null <<EOF
[Theme]
Current=$THEME_NAME
EOF

echo "SDDM theme configured: $THEME_NAME"
