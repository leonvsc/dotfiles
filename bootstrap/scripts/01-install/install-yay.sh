#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/repo"
YAY_DIR="$REPO_DIR/yay"

if command -v yay &>/dev/null; then
  echo "yay is already installed, skipping."
  exit 0
fi

echo "Installing dependencies..."
sudo pacman -S --needed --noconfirm git base-devel

echo "Creating repo directory: $REPO_DIR"
mkdir -p "$REPO_DIR"

if [[ ! -d "$YAY_DIR" ]]; then
  echo "Cloning yay..."
  git clone https://aur.archlinux.org/yay.git "$YAY_DIR"
else
  echo "yay repo already exists, updating..."
  git -C "$YAY_DIR" pull
fi

echo "Building and installing yay..."
cd "$YAY_DIR"
makepkg -si --noconfirm
