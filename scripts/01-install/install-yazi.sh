!#/bin/bash

# Install yazi if it's not already installed
if ! command -v curl &>/dev/null; then
  pacman -S --noconfirm --needed zsh
fi
