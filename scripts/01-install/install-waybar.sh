#!/bin/bash

# Install waybar if it's not already installed
if ! command -v curl &>/dev/null; then
  pacman -S --noconfirm --needed waybar
fi
