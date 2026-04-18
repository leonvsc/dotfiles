#!/bin/bash

# Install git if it's not already installed
if ! command -v git &>/dev/null; then
    pacman -S --noconfirm --needed git
fi