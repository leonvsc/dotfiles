#!/usr/bin/env bash

set -Eeuo pipefail

OH_MY_TMUX_DIR="$HOME/.local/share/tmux/oh-my-tmux"
TMUX_CONFIG_DIR="$HOME/.config/tmux"
TMUX_CONF="$TMUX_CONFIG_DIR/tmux.conf"
TMUX_LOCAL_CONF="$TMUX_CONFIG_DIR/tmux.conf.local"

REPO="https://github.com/gpakosz/.tmux.git"

mkdir -p \
    "$(dirname "$OH_MY_TMUX_DIR")" \
    "$TMUX_CONFIG_DIR"

if [[ -d "$OH_MY_TMUX_DIR/.git" ]]; then
    echo "Oh My Tmux is already installed, updating..."

    git -C "$OH_MY_TMUX_DIR" pull --ff-only
else
    echo "Installing Oh My Tmux..."

    git clone \
        --single-branch \
        --depth 1 \
        "$REPO" \
        "$OH_MY_TMUX_DIR"
fi

echo "Creating tmux.conf symlink..."

ln -sfn \
    "$OH_MY_TMUX_DIR/.tmux.conf" \
    "$TMUX_CONF"

# chezmoi will later manage our customized tmux.conf.local.
# Create the upstream default only when no local config exists yet.
if [[ ! -e "$TMUX_LOCAL_CONF" ]]; then
    cp \
        "$OH_MY_TMUX_DIR/.tmux.conf.local" \
        "$TMUX_LOCAL_CONF"
fi

echo "Oh My Tmux installed."

echo "tmux.conf:       $TMUX_CONF"
echo "tmux.conf.local: $TMUX_LOCAL_CONF"
