#!/usr/bin/env bash
set -euo pipefail

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "Oh My Zsh is already installed, skipping."
  exit 0
fi

if ! command -v zsh &>/dev/null; then
  echo "zsh is not installed. Add it to packages.txt first."
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "git is not installed. Add it to packages.txt first."
  exit 1
fi

if ! command -v curl &>/dev/null; then
  echo "curl is not installed. Add it to packages.txt first."
  exit 1
fi

echo "Installing Oh My Zsh..."

RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
  "" --unattended
