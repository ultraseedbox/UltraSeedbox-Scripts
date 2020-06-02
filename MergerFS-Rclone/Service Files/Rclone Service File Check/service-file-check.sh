#!/bin/bash

# Rclone VFS Service File Checker by Xan#7777

  echo "Which Service file you want to check?"
  echo "1) rclone-normal.service"
  echo "2) rclone-vfs.service"
  echo "3) Exit"
  read -rp "Select an option: " option

case $option in
  1) wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/MergerFS-Rclone/Service%20Files/Rclone%20Service%20File%20Check/normal-check.sh && chmod +x normal-check.sh && ./normal-check.sh && rm normal-check.sh ;;
  2) wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/MergerFS-Rclone/Service%20Files/Rclone%20Service%20File%20Check/vfs-check.sh && chmod +x vfs-check.sh && ./vfs-check.sh && rm vfs-check.sh ;;
  3) rm -- "$0"; exit 0 ;;
esac