# Arch Install

This directory contains a minimal Arch Linux installer for this dotfiles setup.

The installer creates an encrypted Btrfs Arch installation with systemd-boot,
Plymouth, NetworkManager, and a small set of base packages. The dotfiles
bootstrap is intentionally not run automatically. Run it manually after the
first reboot.

## Target Setup

The installer will erase the configured disk and create:

- EFI System Partition mounted at `/boot`
- LUKS2 encrypted root partition
- Btrfs filesystem inside LUKS
- Btrfs subvolume `@` mounted at `/`
- Btrfs subvolume `@home` mounted at `/home`
- Btrfs subvolume `@snapshots` mounted at `/.snapshots`
- Btrfs subvolume `@var_log` mounted at `/var/log`
- Btrfs subvolume `@swap` mounted at `/swap`
- Btrfs swapfile at `/swap/swapfile`
- systemd-boot
- Plymouth for the encrypted boot prompt
- NetworkManager enabled for networking after reboot

## Base Packages

The installer installs:

```text
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
```

It also installs either `amd-ucode` or `intel-ucode` automatically when the CPU
vendor can be detected.

## Before You Start

Boot the official Arch Linux ISO in UEFI mode.

Verify UEFI mode:

```bash
ls /sys/firmware/efi/efivars
```

If this path does not exist, reboot and select the UEFI boot option for the USB
drive.

## Connect To Wi-Fi

On a laptop, connect to Wi-Fi from the live ISO before cloning the repo.

Start `iwctl`:

```bash
iwctl
```

List wireless devices:

```text
device list
```

Scan for networks, replacing `wlan0` with your device name:

```text
station wlan0 scan
```

List networks:

```text
station wlan0 get-networks
```

Connect to your network:

```text
station wlan0 connect "Your WiFi Name"
```

Exit `iwctl`:

```text
exit
```

Test internet:

```bash
ping -c 3 archlinux.org
```

If DNS does not work but pinging an IP does, restart systemd-resolved:

```bash
systemctl restart systemd-resolved
```

## Optional: Update Live ISO Keyring

If package installation fails due to keyring issues, update the keyring first:

```bash
pacman -Sy archlinux-keyring
```

## Clone This Repository

Install Git in the live ISO if needed:

```bash
pacman -Sy git
```

Clone the repository:

```bash
git clone https://github.com/leonvsc/dotfiles.git /root/dotfiles
cd /root/dotfiles
```

## Configure The Installer

Copy the example config:

```bash
cp arch/config.example.env arch/config.env
```

Edit the config:

```bash
vim arch/config.env
```

Example config:

```bash
DISK="/dev/nvme0n1"
HOSTNAME="arch"
USERNAME="leon"
TIMEZONE="Europe/Amsterdam"
LOCALE="en_US.UTF-8"
KEYMAP="us"
EFI_SIZE="1GiB"
SWAP_SIZE="16G"
CRYPT_NAME="cryptroot"
```

Check the target disk carefully:

```bash
lsblk
```

Set `DISK` to the whole disk, not a partition.

Valid examples:

```bash
DISK="/dev/nvme0n1"
DISK="/dev/sda"
DISK="/dev/mmcblk0"
```

Invalid examples:

```bash
DISK="/dev/nvme0n1p1"
DISK="/dev/sda1"
```

## Run The Installer

Run the installer as root:

```bash
./arch/install.sh
```

The installer will show the selected disk and ask for two confirmations before
erasing anything:

```text
Type the target disk path to continue: /dev/nvme0n1
Type ERASE to permanently wipe this disk: ERASE
```

After this point, all data on the configured disk will be destroyed.

## During Installation

You will be prompted for:

- LUKS encryption passphrase
- root password
- user password

The user is created with a home directory:

```bash
useradd -m -G wheel -s /bin/bash "$USERNAME"
```

The default shell is initially Bash because Zsh is installed later by the
dotfiles bootstrap.

## Boot Configuration

The installer configures `mkinitcpio` with systemd encryption and Plymouth:

```bash
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block plymouth sd-encrypt filesystems fsck)
```

The boot entry includes:

```text
quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0
```

The encrypted root is unlocked through:

```text
rd.luks.name=<LUKS_UUID>=cryptroot
```

## After Installation

When the installer finishes, reboot:

```bash
umount -R /mnt
cryptsetup close cryptroot
reboot
```

Remove the USB drive when the system restarts.

## First Boot

Unlock the disk at the Plymouth prompt.

Log in with the user created during installation.

NetworkManager is enabled, so networking after reboot can be managed with
`nmcli`, `nmtui`, or a desktop applet after the full bootstrap is installed.

For Wi-Fi from the terminal, use:

```bash
nmtui
```

Or use `nmcli`:

```bash
nmcli device wifi list
nmcli device wifi connect "Your WiFi Name" password "your-password"
```

## Run Dotfiles Bootstrap

Clone the repository if it is not already present:

```bash
mkdir -p ~/code
git clone https://github.com/leonvsc/dotfiles.git ~/code/dotfiles
```

Run the bootstrap:

```bash
cd ~/code/dotfiles/bootstrap
./install.sh
```

The bootstrap installs the rest of the packages, configures services, applies
chezmoi dotfiles, installs the SDDM theme, and performs final setup.

## Notes

This installer intentionally does not configure:

- hibernation
- Secure Boot
- Snapper or Timeshift snapshots
- NVIDIA drivers
- desktop environment setup before the dotfiles bootstrap
- automatic dotfiles bootstrap after reboot
