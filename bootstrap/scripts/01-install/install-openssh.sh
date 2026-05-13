#!/bin/bash

# Install openssh if it's not already installed
if ! command -v ssh &>/dev/null; then
  pacman -S --noconfirm --needed openssh
fi
