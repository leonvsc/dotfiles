#!/usr/bin/env bash
set -euo pipefail

services=(
  NetworkManager
  ufw
)

echo
echo "==> Enabling system services"

for service in "${services[@]}"; do
  if systemctl list-unit-files "$service.service" &>/dev/null; then
    echo "Enabling and starting: $service"
    sudo systemctl enable --now "$service"
  else
    echo "Service not found, skipping: $service"
  fi
done

echo
echo "==> Enabling display manager"

if systemctl list-unit-files sddm.service &>/dev/null; then
  echo "Enabling SDDM"
  sudo systemctl enable sddm
else
  echo "SDDM service not found, skipping."
fi
