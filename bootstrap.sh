#!/usr/bin/env bash

set -Eeuo pipefail

REPO="leonvsc/dotfiles"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
CHEZMOI_BIN="$HOME/.local/bin/chezmoi"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

info() {
    printf '\n\033[1;34m==>\033[0m %s\n' "$1"
}

error() {
    printf '\n\033[1;31mERROR:\033[0m %s\n' "$1" >&2
    exit 1
}

run_as_root() {
    sudo "$@"
}

# -----------------------------------------------------------------------------
# Sanity checks
# -----------------------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    error "Do not run this bootstrap as root or with sudo. Run it as your normal user."
fi

[[ "$(uname -s)" == "Linux" ]] \
    || error "This bootstrap currently supports Linux only."

[[ -r /etc/os-release ]] \
    || error "Could not determine Linux distribution."

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

command -v sudo >/dev/null 2>&1 \
    || error "sudo is required."

info "Detected ${PRETTY_NAME:-Linux}"

# -----------------------------------------------------------------------------
# Bootstrap dependencies
# -----------------------------------------------------------------------------

info "Installing bootstrap dependencies"

run_as_root apt-get update

run_as_root apt-get install -y \
    ca-certificates \
    curl \
    git

# -----------------------------------------------------------------------------
# Chezmoi
# -----------------------------------------------------------------------------

if command -v chezmoi >/dev/null 2>&1; then
    CHEZMOI_BIN="$(command -v chezmoi)"
    info "chezmoi is already installed"
else
    info "Installing chezmoi"

    mkdir -p "$HOME/.local/bin"

    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- \
        -b "$HOME/.local/bin"

    [[ -x "$CHEZMOI_BIN" ]] \
        || error "chezmoi installation failed."
fi

export PATH="$HOME/.local/bin:$PATH"

info "chezmoi version: $("$CHEZMOI_BIN" --version)"

# -----------------------------------------------------------------------------
# Initialize repository
# -----------------------------------------------------------------------------

info "Initializing dotfiles repository"

info "Initializing dotfiles repository from branch: $DOTFILES_BRANCH"

"$CHEZMOI_BIN" init \
    --branch "$DOTFILES_BRANCH" \
    "$REPO"

SOURCE_PATH="$("$CHEZMOI_BIN" source-path)"

REPO_ROOT="$(
    git -C "$SOURCE_PATH" rev-parse --show-toplevel
)"

[[ -d "$REPO_ROOT/scripts" ]] \
    || error "Could not locate dotfiles scripts directory."

info "Dotfiles repository available at $REPO_ROOT"

# -----------------------------------------------------------------------------
# Install server packages
# -----------------------------------------------------------------------------

info "Installing server packages"

"$REPO_ROOT/scripts/install-packages-ubuntu.sh"

# -----------------------------------------------------------------------------
# Install shell environment
# -----------------------------------------------------------------------------

info "Installing Oh My Zsh"
"$REPO_ROOT/scripts/install-oh-my-zsh.sh"

info "Installing Zsh plugins"
"$REPO_ROOT/scripts/install-zsh-plugins.sh"

info "Installing Oh My Tmux"
"$REPO_ROOT/scripts/install-oh-my-tmux.sh"

# -----------------------------------------------------------------------------
# Install command-line tools
# -----------------------------------------------------------------------------

info "Installing Oh My Posh"
"$REPO_ROOT/scripts/install-oh-my-posh.sh"

info "Installing lazygit"
"$REPO_ROOT/scripts/install-lazygit.sh"

info "Installing ssh-pick"
"$REPO_ROOT/scripts/install-ssh-pick.sh"

# -----------------------------------------------------------------------------
# Ubuntu compatibility
# -----------------------------------------------------------------------------

# Ubuntu installs fd as "fdfind". Many tools expect the executable to be
# called "fd".
if command -v fdfind >/dev/null 2>&1 \
    && ! command -v fd >/dev/null 2>&1; then

    info "Creating fd compatibility symlink"

    mkdir -p "$HOME/.local/bin"
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# -----------------------------------------------------------------------------
# Apply dotfiles
# -----------------------------------------------------------------------------

info "Applying dotfiles"

"$CHEZMOI_BIN" apply

# -----------------------------------------------------------------------------
# Default shell
# -----------------------------------------------------------------------------

ZSH_PATH="$(command -v zsh)"

CURRENT_SHELL="$(
    getent passwd "$USER" | cut -d: -f7
)"

if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
    info "Setting Zsh as default shell"
    run_as_root chsh -s "$ZSH_PATH" "$USER"
else
    info "Zsh is already the default shell"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------

printf '\n'
printf '\033[1;32mBootstrap completed successfully.\033[0m\n'
printf '\n'
printf 'Log out and back in to start a new Zsh session.\n'
