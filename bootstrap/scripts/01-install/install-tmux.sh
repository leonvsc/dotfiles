#!/bin/bash

# Install tmux if it's not already installed
if ! command -v tmux &>/dev/null; then
  pacman -S --noconfirm --needed tmux
fi
