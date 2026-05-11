!#/bin/bash

# Install zsh if it's not already installed
if ! command -v zsh &>/dev/null; then
  pacman -S --noconfirm --needed zsh
fi
