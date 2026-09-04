#!/usr/bin/env bash

set -Eeuo pipefail

REPO="leonvsc/dotfiles"
CHEZMOI_BIN="$HOME/.local/bin/chezmoi"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info() {
    printf '\n\033[1;34m==>\033[0m %s\n' "$1"
}

error() {
    printf '\n\033[1;31mERROR:\033[0m %s\n' "$1" >&2
    exit 1
}

run_as_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

# ---------------------------------------------------------------------------
# OS checks
# ---------------------------------------------------------------------------

[[ "$(uname -s)" == "Linux" ]] || error "This bootstrap currently supports Linux only."

[[ -r /etc/os-release ]] || error "Could not determine Linux distribution."

# shellcheck disable=SC1091
source /etc/os-release

case "${ID:-}" in
    ubuntu|debian)
        ;;
    *)
        if [[ "${ID_LIKE:-}" != *debian* ]]; then
            error "Unsupported distribution: ${PRETTY_NAME:-unknown}"
        fi
        ;;
esac

info "Detected ${PRETTY_NAME:-Linux}"

# ---------------------------------------------------------------------------
# Privileges
# ---------------------------------------------------------------------------

if [[ $EUID -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    error "sudo is required when bootstrap is not executed as root."
fi

# ---------------------------------------------------------------------------
# Bootstrap packages
# ---------------------------------------------------------------------------

info "Installing bootstrap dependencies"

run_as_root apt-get update

run_as_root apt-get install -y \
    ca-certificates \
    curl \
    git

# ---------------------------------------------------------------------------
# Chezmoi
# ---------------------------------------------------------------------------

if command -v chezmoi >/dev/null 2>&1; then
    CHEZMOI_BIN="$(command -v chezmoi)"
    info "chezmoi is already installed"
else
    info "Installing chezmoi"

    mkdir -p "$HOME/.local/bin"

    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- \
        -b "$HOME/.local/bin"

    [[ -x "$CHEZMOI_BIN" ]] || error "chezmoi installation failed."
fi

info "chezmoi version: $("$CHEZMOI_BIN" --version)"

# ---------------------------------------------------------------------------
# Dotfiles
# ---------------------------------------------------------------------------

info "Initializing dotfiles repository"

"$CHEZMOI_BIN" init "$REPO"

info "Bootstrap foundation completed"

printf '\nDotfiles source initialized at:\n  %s\n' "$("$CHEZMOI_BIN" source-path)"
printf '\nDotfiles have NOT been applied yet.\n'
