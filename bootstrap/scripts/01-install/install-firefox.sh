#!/bin/bash

# Install firefox if it's not already installed
if ! command -v firefox &>/dev/null; then
  pacman -S --noconfirm --needed firefox
fi
