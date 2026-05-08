#!/bin/bash

# Install wl-clipboard if it's not already installed
if ! command -v curl &>/dev/null; then
  pacman -S --noconfirm --needed wl-clipboard
fi
