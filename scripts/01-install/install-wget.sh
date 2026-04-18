#!/bin/bash

# Install wget if it's not already installed
if ! command -v wget &>/dev/null; then
    pacman -S --noconfirm --needed wget
fi