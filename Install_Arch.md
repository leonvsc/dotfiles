# Arch Installation

I install my systems with a vanilla ArchLinux ISO. You can find more info [here](https://archlinux.org/).

[Reference](https://wiki.archlinux.org/title/Installation_guide).

Boot up the ISO.

I like to do my Arch installs over SSH. First find the Ip Address of the machine you are intalling Arch on.

```bash
ip a
```

Change the root password with `passwd`
SSH into the machine with `ssh root@ipaddress`.

Check if your machine has a internet connection. Check this with `ping google.com`.

Partition your disk with `cfdisk`. For examples take a look at [ArchWiki](https://wiki.archlinux.org/title/Partitioning#Example_layouts).
I go with a boot and root partition.

Format your partitions.

```bash
mkfs.ext4 /dev/root_partition
mkfs.fat -F 32 /dev/efi_system_partition
```

Mount the partitions to /mnt.

```bash
mount /dev/root_partition /mnt
mount --mkdir /dev/efi_system_partition /mnt/boot
```

Select the mirrors.

```bash
reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
```

Install the necessary packages.

```bash
pacstrap -K /mnt base linux linux-firmware vim
```

Generate fstab.

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Chroot into the system

```bash
arch-chroot /mnt
```

Set the timezone.

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

Generate the locale.

```bash
vim /etc/locale.gen
```

Uncomment your locale. In my case it is en_US.UTF-8 UTF-8.
Generate the locale with `locale-gen`.

Create /etc/locale.conf and set the LANG variable on the locale you uncommented.
`LANG=en_US.UTF-8`.

Create a hostname in `/etc/hostname`.

`myhostname`

Set a new root password with `passwd`.

Install some base packages.

```bash
pacman -S grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers bluez bluez-utils cups xdg-utils xdg-user-dirs pulseaudio alsa-utils
```

You also want to install the microcode of your CPU. You can leanr more about that [here](https://wiki.archlinux.org/title/Microcode).

Install bootloader

```bash
grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

Reboot!
