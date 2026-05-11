#!/bin/bash

# Install waybar if it's not already installed
if ! command -v waybar &>/dev/null; then
  pacman -S --noconfirm --needed waybar
fi
