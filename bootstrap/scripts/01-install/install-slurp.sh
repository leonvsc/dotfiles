#!/bin/bash

# Install slurp if it's not already installed
if ! command -v slurp &>/dev/null; then
  pacman -S --noconfirm --needed slurp
fi
