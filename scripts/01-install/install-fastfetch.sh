#!/bin/bash

# Install fastfetch if it's not already installed
if ! command -v fastfetch &>/dev/null; then
  pacman -S --noconfirm --needed fastfetch
fi
