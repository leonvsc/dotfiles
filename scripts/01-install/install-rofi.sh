#!/bin/bash

# Install rofi if it's not already installed
if ! command -v rofi &>/dev/null; then
  pacman -S --noconfirm --needed rofi
fi
