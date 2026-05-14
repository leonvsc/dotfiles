#!/usr/bin/env bash
set -euo pipefail

OH_MY_TMUX_DIR="$HOME/.local/share/tmux/oh-my-tmux"
TMUX_CONFIG_DIR="$HOME/.config/tmux"
TMUX_CONF="$TMUX_CONFIG_DIR/tmux.conf"
TMUX_LOCAL_CONF="$TMUX_CONFIG_DIR/tmux.conf.local"

INSTALL_URL="https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)"

if [[ -d "$OH_MY_TMUX_DIR/.git" ]]; then
  echo "Oh My Tmux is already installed, updating..."
  git -C "$OH_MY_TMUX_DIR" pull --ff-only || true
else
  echo "Installing Oh My Tmux..."
  curl -fsSL "$INSTALL_URL" | bash
fi

if [[ -L "$TMUX_CONF" || -f "$TMUX_CONF" ]]; then
  echo "tmux.conf exists: $TMUX_CONF"
else
  echo "Warning: tmux.conf was not found after installation."
fi

if [[ -f "$TMUX_LOCAL_CONF" ]]; then
  echo "tmux.conf.local exists: $TMUX_LOCAL_CONF"
else
  echo "Warning: tmux.conf.local was not found after installation."
fi
