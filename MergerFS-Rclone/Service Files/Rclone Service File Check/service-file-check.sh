#!/bin/bash

# Rclone VFS Service File Checker by Xan#7777

  echo "Which Service file you want to check?"
  echo "1) rclone-normal.service"
  echo "2) rclone-vfs.service"
  echo "3) Exit"

while true :
do
read -rp "Select an option: " option
case $option in
  1) curl https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/MergerFS-Rclone/Service%20Files/Rclone%20Service%20File%20Check/normal-check.sh | bash && wait ;;
  2) curl https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/MergerFS-Rclone/Service%20Files/Rclone%20Service%20File%20Check/vfs-check.sh | bash && wait ;;
  3) exit 0 ;;
  *) echo "Wrong option $option"
  esac
done