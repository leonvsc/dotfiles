# My setup

## Arch installation with [Anarchy](https://anarchyinstaller.gitlab.io/)

Do a basic Anarchy install with your preferences. I go for a install with base, base-devel, bash, grub, networkmanager.

I don't install a desktop environment or window manager. My script will do that later.

Add a new user acount. Make sure you give the new user sudo privilege.

Let the installer do his thing. When the installer is done reboot the system.

When booted into your new system you need to edit the sudoers file.

Login with the root user.

To edit the sudoers file we can use vim.
vim comes preinstalled with Anarchy so you can use:

```bash
EDITOR=vim visudo
```

Uncomment the following line: `%wheel ALL=(ALL:ALL) ALL`

This will make sure that users from the wheel group can execute sudo commands. Our newly added user can now execute sudo commands.

## Install the necessary programs

Now we can install my script to install all the necessary programs.
Use the following command:

```bash
$ sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/leonvsc/dotfiles/main/bin/install)"
```
