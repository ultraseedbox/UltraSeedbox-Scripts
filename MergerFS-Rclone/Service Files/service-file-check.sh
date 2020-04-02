#!/bin/bash

#USB Rclone service file checker by Xan#7777

echo "Welcome to USB Rclone Service file checker."
echo ""
echo "Which service file do you want to check?"
echo "1) Rclone Normal"
echo "2) Rclone VFS"
echo "3) Exit"

read -rp "Select an option: " option1

case $option1 in
  1)
    echo "What do you want to do?"
    echo "1) Show ExecStart"
    echo "2) Show ExecStop"
    echo "3) Execute ExecStart"
    echo "4) Exit"

    read -rp "Select an option: " option2
    case $option2 in
      1)
        cat "$HOME"/.config/systemd/user/rclone-normal.service | sed -n '/^ExecStart=/,$p' | sed -n '/^ExecStop=/q;p' | sed 's/^ExecStart=//g'
        ;;
      2)
        cat "$HOME"/.config/systemd/user/rclone-normal.service | sed -n '/^ExecStop=/,$p' | sed -n '/^Restart=/q;p' | sed 's/^ExecStop=//g'
        ;;
      3)
        cat "$HOME"/.config/systemd/user/rclone-normal.service | sed -n '/^ExecStart=/,$p' | sed -n '/^ExecStop=/q;p' | sed 's/^ExecStart=//g' | bash
        ;;
      4)
        echo "Bye."
        exit 0
        ;;
      *) echo "Wrong option $option2"
    esac
  2)
    echo "What do you want to do?"
    echo "1) Show ExecStart"
    echo "2) Show ExecStop"
    echo "3) Execute ExecStart"
    echo "4) Exit"

    read -rp "Select an option: " option2
    case $option2 in
      1)
        cat "$HOME"/.config/systemd/user/rclone-vfs.service | sed -n '/^ExecStart=/,$p' | sed -n '/^ExecStop=/q;p' | sed 's/^ExecStart=//g'
        ;;
      2)
        cat "$HOME"/.config/systemd/user/rclone-vfs.service | sed -n '/^ExecStop=/,$p' | sed -n '/^Restart=/q;p' | sed 's/^ExecStop=//g'
        ;;
      3)
        cat "$HOME"/.config/systemd/user/rclone-vfs.service | sed -n '/^ExecStart=/,$p' | sed -n '/^ExecStop=/q;p' | sed 's/^ExecStart=//g' | bash
        ;;
      4)
        echo "Bye."
        exit 0
        ;;
      *) echo "Wrong option $option2"
  3)
    echo "Bye."
    exit 0
    ;;
  *) echo "Wrong option $option2"
esac