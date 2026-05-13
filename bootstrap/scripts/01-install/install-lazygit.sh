#!/bin/bash

# Install lazygit if it's not already installed
if ! command -v lazygit &>/dev/null; then
  pacman -S --noconfirm --needed lazygit
fi
