#!/bin/bash

# Install timeshift if it's not already installed
if ! command -v timeshift &>/dev/null; then
  pacman -S --noconfirm --needed timeshift
fi
