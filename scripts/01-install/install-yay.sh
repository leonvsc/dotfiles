!#/bin/bash

set -e

REPO_DIR="$HOME/repo"
YAY_DIR="$REPO_DIR/yay"

echo "Installing dependencies..."
sudo pacman -S --needed git base-devel

echo "Create Repo-folder: $REPO_DIR"
mkdir -p "$REPO_DIR"

cd "$REPO_DIR"

if [ ! -d "$YAY_DIR" ]; then
  echo "cloning yay..."
  git clone https://aur.archlinux.org/yay.git
else
  echo "yay already exists, updating..."
  cd "$YAY_DIR"
  git pull
  cd "$REPO_DIR"
fi

cd "$YAY_DIR"

echo "building and installing yay..."
makepkg -si
