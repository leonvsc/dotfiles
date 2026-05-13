#!/bin/bash

# Install unzip if it's not already installed
if ! command -v unzip &>/dev/null; then
  pacman -S --noconfirm --needed unzip
fi
