#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUR_PACKAGES_FILE="$SCRIPT_DIR/aur-packages.txt"

if [[ ! -f "$AUR_PACKAGES_FILE" ]]; then
  echo "AUR packages file not found, skipping."
  exit 0
fi

if [[ ! -s "$AUR_PACKAGES_FILE" ]]; then
  echo "AUR packages file is empty, skipping."
  exit 0
fi

if ! command -v yay &>/dev/null; then
  echo "yay is not installed. Run install-yay.sh first."
  exit 1
fi

echo
echo "==> Installing AUR packages"
yay -S --needed --noconfirm - <"$AUR_PACKAGES_FILE"
