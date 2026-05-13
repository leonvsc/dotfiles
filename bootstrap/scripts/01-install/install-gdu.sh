#!/bin/bash

# Install gdu if it's not already installed
if ! command -v gdu &>/dev/null; then
  pacman -S --noconfirm --needed gdu
fi
