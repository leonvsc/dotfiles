#!/bin/bash

# Install kitty if it's not already installed
if ! command -v kitty &>/dev/null; then
  pacman -S --noconfirm --needed kitty
fi
