#!/bin/bash

# Rclone Normal Service File Checker by Xan#7777

  echo "What do you want to do?"
  echo "1) Show ExecStart"
  echo "2) Show ExecStop"
  echo "3) Execute ExecStart"
  echo "4) Exit"
  read -rp "Select an option: " option

case $option in
  1) cat "$HOME"/.config/systemd/user/rclone-normal.service | sed -n '/^ExecStart=/,$p' | sed -n '/^ExecStop=/q;p' | sed 's/^ExecStart=//g' ;;
  2) cat "$HOME"/.config/systemd/user/rclone-normal.service | sed -n '/^ExecStop=/,$p' | sed -n '/^Restart=/q;p' | sed 's/^ExecStop=//g' ;;
  3) cat "$HOME"/.config/systemd/user/rclone-normal.service | sed -n '/^ExecStart=/,$p' | sed -n '/^ExecStop=/q;p' | sed 's/^ExecStart=//g' | bash ;;
  4) exit 0 ;;
esac