#!/bin/bash

# Install podman if it's not already installed
if ! command -v podman &>/dev/null; then
  pacman -S --noconfirm --needed podman podman-compose
fi
