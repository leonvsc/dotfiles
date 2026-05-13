#!/bin/bash

# Install neovim if it's not already installed
if ! command -v neovim &>/dev/null; then
  pacman -S --noconfirm --needed neovim
fi
