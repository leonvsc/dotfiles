#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if ! command -v chezmoi &>/dev/null; then
  echo "chezmoi is not installed. Add it to packages.txt first."
  exit 1
fi

echo
echo "==> Setting up chezmoi"
echo "Using source directory: $REPO_ROOT"

chezmoi apply --source="$REPO_ROOT"
