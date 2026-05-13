#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if ! command -v chezmoi &>/dev/null; then
  echo "chezmoi is not installed. Add it to packages.txt first."
  exit 1
fi

echo
echo "==> Setting up chezmoi"

if [[ -d "$HOME/.local/share/chezmoi" ]]; then
  echo "chezmoi source directory already exists."
  echo "Applying dotfiles..."
  chezmoi apply
else
  echo "Initializing chezmoi from local repository:"
  echo "$REPO_ROOT"

  chezmoi init --source="$REPO_ROOT"
  chezmoi apply
fi
