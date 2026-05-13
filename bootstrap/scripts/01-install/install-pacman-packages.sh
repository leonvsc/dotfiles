#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_from_file() {
  local file="$1"
  local name="$2"

  if [[ ! -f "$file" ]]; then
    echo "File not found: $file"
    exit 1
  fi

  if [[ ! -s "$file" ]]; then
    echo "File is empty, skipping: $file"
    return
  fi

  echo
  echo "==> Installing: $name"
  sudo pacman -S --needed --noconfirm - <"$file"
}

echo
echo "==> Updating system"
sudo pacman -Syu --noconfirm

install_from_file "$SCRIPT_DIR/packages.txt" "packages"
install_from_file "$SCRIPT_DIR/fonts.txt" "fonts"
