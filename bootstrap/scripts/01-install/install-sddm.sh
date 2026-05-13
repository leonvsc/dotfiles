#!/bin/bash

# Install sddm if it's not already installed
if ! command -v sddm &>/dev/null; then
  pacman -S --noconfirm --needed sddm
fi
