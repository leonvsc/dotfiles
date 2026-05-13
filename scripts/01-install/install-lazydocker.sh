#!/bin/bash

# Install lazydocker if it's not already installed
if ! command -v lazydocker &>/dev/null; then
  pacman -S --noconfirm --needed lazydocker
fi
