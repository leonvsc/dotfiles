#!/usr/bin/env bash
set -euo pipefail

echo
echo "==> Running final setup"

echo "Creating common directories..."
mkdir -p "$HOME/Downloads"
mkdir -p "$HOME/Documents"
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/code"
mkdir -p "$HOME/repo"

if command -v zsh &>/dev/null; then
  ZSH_PATH="$(command -v zsh)"

  if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "Changing default shell to zsh..."
    chsh -s "$ZSH_PATH"
  else
    echo "zsh is already the default shell."
  fi
else
  echo "zsh is not installed, skipping default shell change."
fi

echo
echo "Post-install notes:"
echo "- Reboot your system after this installer finishes."
echo "- Check enabled services with: systemctl list-unit-files --state=enabled"
echo "- Check firewall status with: sudo ufw status"
echo "- Check SDDM theme config with: cat /etc/sddm.conf.d/theme.conf"
