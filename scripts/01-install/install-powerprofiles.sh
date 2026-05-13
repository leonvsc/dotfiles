#!/bin/bash

# Install powerprofiles if it's not already installed
if ! command -v powerprofilesctl &>/dev/null; then
  pacman -S --noconfirm --needed power-profiles-daemon
fi
