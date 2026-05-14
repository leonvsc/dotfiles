#!/usr/bin/env bash
set -euo pipefail

OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
CUSTOM_PLUGINS_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}/plugins"

if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
  echo "Oh My Zsh is not installed. Run install-oh-my-zsh.sh first."
  exit 1
fi

mkdir -p "$CUSTOM_PLUGINS_DIR"

install_or_update_plugin() {
  local name="$1"
  local repo_url="$2"
  local target_dir="$CUSTOM_PLUGINS_DIR/$name"

  if [[ -d "$target_dir/.git" ]]; then
    echo "Updating $name..."
    git -C "$target_dir" pull --ff-only || true
  else
    echo "Installing $name..."
    git clone "$repo_url" "$target_dir"
  fi
}

install_or_update_plugin \
  "zsh-autosuggestions" \
  "https://github.com/zsh-users/zsh-autosuggestions.git"

install_or_update_plugin \
  "zsh-syntax-highlighting" \
  "https://github.com/zsh-users/zsh-syntax-highlighting.git"
