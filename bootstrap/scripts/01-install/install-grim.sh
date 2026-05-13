#!/bin/bash

# Install grim if it's not already installed
if ! command -v grim &>/dev/null; then
  pacman -S --noconfirm --needed grim
fi
