#!/bin/bash

# Install wireguard-tools if it's not already installed
if ! command -v curl &>/dev/null; then
  pacman -S --noconfirm --needed wireguard-tools
fi
