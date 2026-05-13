#!/usr/bin/env bash

choice=$(printf "  Shutdown\n  Restart\n  Sleep\n  Lock\n  Logout" | rofi -dmenu -p "Power menu")

case "$choice" in
  *Shutdown)
    systemctl poweroff
    ;;
  *Restart)
    systemctl reboot
    ;;
  *Sleep)
    systemctl suspend
    ;;
  *Lock)
    swaylock
    ;;
  *Logout)
    hyprctl dispatch exit || swaymsg exit
    ;;
esac
