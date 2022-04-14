# WIP My setup

## Arch installation with [Anarchy](https://anarchyinstaller.gitlab.io/)

Do a basic Anarchy install with your preferences. I go for a minimal install with base, base-devel, bash, grub, networkmanager.

I don't install a desktop environment or window manager. My script will do that later.

Add a new user acount. Make sure you give the new user sudo privilege.

Let the installer do his thing. When the installer is done reboot the system.

When booted into your new system we can install the necessary programs.

## Install the necessary programs

Login with the root user.

We can use my script to install all the necessary programs.
Use the following command:

```bash
$ sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/leonvsc/dotfiles/main/bin/dotfiles)"
```
