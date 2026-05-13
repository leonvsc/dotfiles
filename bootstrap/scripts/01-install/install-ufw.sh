#!/bin/bash

# Install ufw if it's not already installed
if ! command -v ufw &>/dev/null; then
  pacman -S --noconfirm --needed ufw
fi
