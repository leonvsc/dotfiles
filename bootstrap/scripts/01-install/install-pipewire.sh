#!/bin/bash

# Install pipewire if it's not already installed
if ! command -v pipewire &>/dev/null; then
  pacman -S --noconfirm --needed pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber
fi
