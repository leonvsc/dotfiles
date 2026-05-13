#!/bin/bash

# Install ripgrep if it's not already installed
if ! command -v ripgrep &>/dev/null; then
  pacman -S --noconfirm --needed ripgrep
fi
