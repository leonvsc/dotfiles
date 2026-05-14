#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"
CHROOT_SCRIPT="$SCRIPT_DIR/chroot.sh"

BTRFS_OPTIONS="noatime,compress=zstd,ssd,discard=async,space_cache=v2"

die() {
  echo "Error: $*" >&2
  exit 1
}

require_command() {
  local command="$1"

  command -v "$command" &>/dev/null || die "Required command not found: $command"
}

partition_path() {
  local disk="$1"
  local number="$2"

  case "$disk" in
    *[0-9]) printf '%sp%s\n' "$disk" "$number" ;;
    *) printf '%s%s\n' "$disk" "$number" ;;
  esac
}

detect_microcode_package() {
  if grep -q "GenuineIntel" /proc/cpuinfo; then
    echo "intel-ucode"
  elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "amd-ucode"
  fi
}

validate_config() {
  [[ -n "${DISK:-}" ]] || die "DISK is not set"
  [[ -n "${HOSTNAME:-}" ]] || die "HOSTNAME is not set"
  [[ -n "${USERNAME:-}" ]] || die "USERNAME is not set"
  [[ -n "${TIMEZONE:-}" ]] || die "TIMEZONE is not set"
  [[ -n "${LOCALE:-}" ]] || die "LOCALE is not set"
  [[ -n "${KEYMAP:-}" ]] || die "KEYMAP is not set"
  [[ -n "${EFI_SIZE:-}" ]] || die "EFI_SIZE is not set"
  [[ -n "${SWAP_SIZE:-}" ]] || die "SWAP_SIZE is not set"
  [[ -n "${CRYPT_NAME:-}" ]] || die "CRYPT_NAME is not set"

  [[ -b "$DISK" ]] || die "DISK is not a block device: $DISK"
  [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]] || die "USERNAME contains unsupported characters: $USERNAME"
  [[ "$HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]] || die "HOSTNAME contains unsupported characters: $HOSTNAME"
}

confirm_disk_wipe() {
  local disk_confirmation erase_confirmation

  echo
  echo "Target disk: $DISK"
  lsblk "$DISK"
  echo
  echo "This will permanently erase all data on $DISK."
  read -r -p "Type the target disk path to continue: " disk_confirmation
  [[ "$disk_confirmation" == "$DISK" ]] || die "Disk confirmation did not match"

  read -r -p "Type ERASE to permanently wipe this disk: " erase_confirmation
  [[ "$erase_confirmation" == "ERASE" ]] || die "Erase confirmation did not match"
}

mount_btrfs_subvolumes() {
  mount -o "$BTRFS_OPTIONS,subvol=@" "/dev/mapper/$CRYPT_NAME" /mnt
  mkdir -p /mnt/{boot,home,.snapshots,var/log,swap}
  mount -o "$BTRFS_OPTIONS,subvol=@home" "/dev/mapper/$CRYPT_NAME" /mnt/home
  mount -o "$BTRFS_OPTIONS,subvol=@snapshots" "/dev/mapper/$CRYPT_NAME" /mnt/.snapshots
  mount -o "$BTRFS_OPTIONS,subvol=@var_log" "/dev/mapper/$CRYPT_NAME" /mnt/var/log
  mount -o "noatime,ssd,discard=async,space_cache=v2,subvol=@swap" "/dev/mapper/$CRYPT_NAME" /mnt/swap
  mount -o umask=0077 "$EFI_PARTITION" /mnt/boot
}

echo "==> Starting Arch installer"

[[ "$EUID" -eq 0 ]] || die "Run this script as root from the Arch ISO"
[[ -d /sys/firmware/efi/efivars ]] || die "UEFI mode is required"
[[ -f "$CONFIG_FILE" ]] || die "Config file not found: $CONFIG_FILE. Copy config.example.env to config.env first."
[[ -f "$CHROOT_SCRIPT" ]] || die "chroot.sh not found: $CHROOT_SCRIPT"

echo "==> Checking required commands"
require_command arch-chroot
require_command cryptsetup
require_command genfstab
require_command mkfs.btrfs
require_command mkfs.fat
require_command pacstrap
require_command ping
require_command sgdisk

echo "==> Loading config: $CONFIG_FILE"
# shellcheck source=/dev/null
source "$CONFIG_FILE"
validate_config

echo "==> Checking internet connection"
ping -W 5 -c 3 archlinux.org >/dev/null || die "Internet connection check failed"

EFI_PARTITION="$(partition_path "$DISK" 1)"
ROOT_PARTITION="$(partition_path "$DISK" 2)"
MICROCODE_PACKAGE="$(detect_microcode_package || true)"

BASE_PACKAGES=(
  base
  base-devel
  linux
  linux-firmware
  btrfs-progs
  cryptsetup
  dosfstools
  efibootmgr
  plymouth
  git
  networkmanager
)

if [[ -n "$MICROCODE_PACKAGE" ]]; then
  BASE_PACKAGES+=("$MICROCODE_PACKAGE")
else
  echo "Warning: CPU vendor not detected. Microcode package will not be installed."
fi

confirm_disk_wipe

echo
echo "==> Partitioning $DISK"
swapoff --all || true
umount -R /mnt 2>/dev/null || true
cryptsetup close "$CRYPT_NAME" 2>/dev/null || true

sgdisk --zap-all "$DISK"
sgdisk -n "1:0:+$EFI_SIZE" -t 1:ef00 -c 1:"EFI System Partition" "$DISK"
sgdisk -n "2:0:0" -t 2:8309 -c 2:"Linux LUKS root" "$DISK"
partprobe "$DISK"
udevadm settle

echo
echo "==> Formatting EFI partition"
mkfs.fat -F32 "$EFI_PARTITION"

echo
echo "==> Creating encrypted root partition"
cryptsetup luksFormat --type luks2 "$ROOT_PARTITION"
cryptsetup open "$ROOT_PARTITION" "$CRYPT_NAME"

echo
echo "==> Creating Btrfs filesystem and subvolumes"
mkfs.btrfs -f "/dev/mapper/$CRYPT_NAME"
mount "/dev/mapper/$CRYPT_NAME" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@swap
umount /mnt

echo
echo "==> Mounting target filesystem"
mount_btrfs_subvolumes

echo
echo "==> Installing base system"
pacstrap -K /mnt "${BASE_PACKAGES[@]}"

echo
echo "==> Generating fstab"
genfstab -U /mnt >>/mnt/etc/fstab

echo
echo "==> Preparing chroot installer"
mkdir -p /mnt/root/arch-install
cp "$CONFIG_FILE" /mnt/root/arch-install/config.env
cp "$CHROOT_SCRIPT" /mnt/root/arch-install/chroot.sh
chmod +x /mnt/root/arch-install/chroot.sh

echo
echo "==> Running chroot installer"
arch-chroot /mnt /root/arch-install/chroot.sh

echo
echo "==> Installation complete"
echo "You can now reboot:"
echo "  umount -R /mnt"
echo "  cryptsetup close $CRYPT_NAME"
echo "  reboot"
