#!/bin/bash

# Install fzf if it's not already installed
if ! command -v fzf &>/dev/null; then
  pacman -S --noconfirm --needed fzf
fi
