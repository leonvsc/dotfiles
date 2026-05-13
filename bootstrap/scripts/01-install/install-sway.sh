#!/bin/bash

# Install sway if it's not already installed
if ! command -v sway &>/dev/null; then
  pacman -S --noconfirm --needed sway
fi
