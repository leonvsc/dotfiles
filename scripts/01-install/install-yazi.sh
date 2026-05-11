!#/bin/bash

# Install yazi if it's not already installed
if ! command -v yazi &>/dev/null; then
  pacman -S --noconfirm --needed zsh
fi
