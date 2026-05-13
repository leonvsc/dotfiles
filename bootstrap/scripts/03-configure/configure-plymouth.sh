#!/bin/bash


# Enable the plymouth service
systemctl enable plymouth-start.service

## TODO: Test this statements
# # Append the plymouth hook to the mkinitcpio configuration if it's not already present
# if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
#     sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck plymouth)/' /etc/mkinitcpio.conf
# fi

# # Append quiet and splash to the unified kernel parameters if they're not already present
# if ! grep -q "quiet" /etc/default/grub; then
#     sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& quiet splash/' /etc/default/grub
# fi

# Update the initramfs to include plymouth
mkinitcpio -P