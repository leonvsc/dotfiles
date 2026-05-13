#!/bin/bash

# Install htop if it's not already installed
if ! command -v htop &>/dev/null; then
  pacman -S --noconfirm --needed htop
fi
