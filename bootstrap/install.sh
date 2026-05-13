#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not run this script with sudo. Use: ./install.sh"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Requesting sudo access..."
sudo -v

# Keep sudo alive while this script is running
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

run_script() {
  local script="$1"

  echo
  echo "==> Running: $script"

  if [[ ! -f "$SCRIPT_DIR/$script" ]]; then
    echo "Script not found: $script"
    exit 1
  fi

  bash "$SCRIPT_DIR/$script"
}

echo
echo "==> Installation started"

echo
echo "==> Step 1: Installing packages"
run_script "scripts/01-install/install-pacman-packages.sh"
run_script "scripts/01-install/install-yay.sh"
run_script "scripts/01-install/install-aur-packages.sh"

echo
echo "==> Step 2: Enabling services"
run_script "scripts/02-services/enable-services.sh"

echo
echo "==> Step 3: Applying configuration"
run_script "scripts/03-configure/setup-chezmoi.sh"

echo
echo "==> Installation completed"
