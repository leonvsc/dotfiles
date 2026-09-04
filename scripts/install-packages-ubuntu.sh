#!/usr/bin/env bash

set -Eeuo pipefail

info() {
    printf '\n\033[1;34m==>\033[0m %s\n' "$1"
}

if [[ $EUID -eq 0 ]]; then
    SUDO=()
else
    SUDO=(sudo)
fi

packages=(
    ca-certificates
    coreutils
    curl
    fd-find
    fzf
    gawk
    git
    htop
    neovim
    openssh-client
    ripgrep
    tmux
    unzip
    wget
    zsh
)

info "Installing Ubuntu server packages"

"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y "${packages[@]}"

info "Ubuntu server packages installed"
