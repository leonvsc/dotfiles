#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="/root/arch-install/config.env"
BOOT_ENTRY="/boot/loader/entries/arch.conf"
LOADER_CONF="/boot/loader/loader.conf"
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

die() {
  echo "Error: $*" >&2
  exit 1
}

detect_microcode_initrd() {
  if [[ -f /boot/intel-ucode.img ]]; then
    echo "initrd /intel-ucode.img"
  elif [[ -f /boot/amd-ucode.img ]]; then
    echo "initrd /amd-ucode.img"
  fi
}

replace_or_append_line() {
  local file="$1"
  local pattern="$2"
  local replacement="$3"

  if grep -qE "$pattern" "$file"; then
    sed -i "s|$pattern|$replacement|" "$file"
  else
    printf '%s\n' "$replacement" >>"$file"
  fi
}

[[ -f "$CONFIG_FILE" ]] || die "Config file not found: $CONFIG_FILE"

# shellcheck source=/dev/null
source "$CONFIG_FILE"

[[ -n "${DISK:-}" ]] || die "DISK is not set"
[[ -n "${HOSTNAME:-}" ]] || die "HOSTNAME is not set"
[[ -n "${USERNAME:-}" ]] || die "USERNAME is not set"
[[ -n "${TIMEZONE:-}" ]] || die "TIMEZONE is not set"
[[ -n "${LOCALE:-}" ]] || die "LOCALE is not set"
[[ -n "${KEYMAP:-}" ]] || die "KEYMAP is not set"
[[ -n "${SWAP_SIZE:-}" ]] || die "SWAP_SIZE is not set"
[[ -n "${CRYPT_NAME:-}" ]] || die "CRYPT_NAME is not set"

ROOT_SOURCE="$(findmnt -no SOURCE /)"
ROOT_PARTITION="$(cryptsetup status "$CRYPT_NAME" | awk '/device:/ { print $2 }')"
LUKS_UUID="$(blkid -s UUID -o value "$ROOT_PARTITION")"
MICROCODE_INITRD="$(detect_microcode_initrd || true)"

[[ "$ROOT_SOURCE" == /dev/mapper/$CRYPT_NAME* ]] || die "Unexpected root source: $ROOT_SOURCE"
[[ -n "$LUKS_UUID" ]] || die "Could not determine LUKS UUID"

echo
echo "==> Configuring timezone"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

echo
echo "==> Configuring locale"
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen
printf 'LANG=%s\n' "$LOCALE" >/etc/locale.conf
printf 'KEYMAP=%s\n' "$KEYMAP" >/etc/vconsole.conf

echo
echo "==> Configuring hostname"
printf '%s\n' "$HOSTNAME" >/etc/hostname
cat >/etc/hosts <<EOF
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
EOF

echo
echo "==> Setting root password"
passwd

echo
echo "==> Creating user: $USERNAME"
if id "$USERNAME" &>/dev/null; then
  echo "User already exists: $USERNAME"
else
  useradd -m -G wheel -s /bin/bash "$USERNAME"
fi
passwd "$USERNAME"

echo
echo "==> Enabling sudo for wheel group"
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo
echo "==> Enabling NetworkManager"
systemctl enable NetworkManager

echo
echo "==> Installing systemd-boot"
bootctl install
mkdir -p /boot/loader/entries
cat >"$LOADER_CONF" <<EOF
default arch.conf
timeout 3
console-mode max
editor no
EOF

echo
echo "==> Writing boot entry"
{
  echo "title Arch Linux"
  echo "linux /vmlinuz-linux"
  if [[ -n "$MICROCODE_INITRD" ]]; then
    echo "$MICROCODE_INITRD"
  fi
  echo "initrd /initramfs-linux.img"
  echo "options rd.luks.name=$LUKS_UUID=$CRYPT_NAME root=/dev/mapper/$CRYPT_NAME rootflags=subvol=@ rw quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0"
} >"$BOOT_ENTRY"

echo
echo "==> Configuring mkinitcpio"
[[ -f /usr/lib/initcpio/install/plymouth ]] || die "mkinitcpio Plymouth hook not found"
replace_or_append_line "$MKINITCPIO_CONF" '^HOOKS=.*' 'HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block plymouth sd-encrypt filesystems fsck)'
mkinitcpio -P

echo
echo "==> Creating Btrfs swapfile"
if [[ ! -f /swap/swapfile ]]; then
  btrfs filesystem mkswapfile --size "$SWAP_SIZE" /swap/swapfile
fi

if ! grep -q '^/swap/swapfile ' /etc/fstab; then
  printf '/swap/swapfile none swap defaults 0 0\n' >>/etc/fstab
fi

echo
echo "==> Chroot configuration complete"
echo "After reboot, connect to Wi-Fi and run:"
echo "  mkdir -p ~/code"
echo "  git clone https://github.com/leonvsc/dotfiles.git ~/code/dotfiles"
echo "  cd ~/code/dotfiles/bootstrap"
echo "  ./install.sh"
