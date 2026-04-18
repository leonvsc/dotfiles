#!/bin/bash

# Install plymouth if it's not already installed
if ! command -v plymouth &>/dev/null; then
    pacman -S --noconfirm --needed plymouth
fi
