#!/bin/bash

# Install 7zip if it's not already installed
if ! command -v 7zip &>/dev/null; then
  pacman -S --noconfirm --needed 7zip
fi
