#!/bin/bash

# Install networkmanager if it's not already installed
if ! command -v nmcli &>/dev/null; then
  pacman -S --noconfirm --needed networkmanager
fi
