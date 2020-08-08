#!/bin/bash

echo "What do you want to do?"
echo "1) Create a user"
echo "2) Delete a user"
echo "3) Change a user's password"
echo "4) Exit"
read -p "Select an option: " option

case $option in
  1)
    read -p "FTP Root Folder: " ROOT
    ROOT="${ROOT/#\~/$HOME}"

    input="y"
    while [ "$input" = "y" ]
    do
      read -p "Username: " username
      read -s -p "Password: " password
      echo "$password" | /usr/sbin/ftpasswd --passwd --stdin --file="$HOME/.config/proftpd/proftpd.passwd" --name="$username" --uid="$UID" --home="$ROOT"--shell="$SHELL" --gid="$(id -g $USER)"
      read -p "Do you want to create another user? (y/n) " input
    done
    ;;
  2)
    input="y"
    while [ "$input" = "y" ]
    do
      read -p "Username: " username
      /usr/sbin/ftpasswd --passwd --delete-user --file="$HOME/.config/proftpd/proftpd.passwd" --name="$username"
      read -p "Do you want to delete another user? (y/n) " input
    done
    ;;
  3)
    input="y"
    while [ "$input" = "y" ]
    do
      read -p "Username: " username
      read -s -p "New Password: " password
      echo "$password" | /usr/sbin/ftpasswd --passwd --stdin --change-password --file="$HOME/.config/proftpd/proftpd.passwd" --name="$username"
      read -p "Do you want to change another user's password? (y/n) " input
    done
    ;;
  4)
    exit
    ;;
  *)
    exec $(readlink -f "$0")
    ;;
esac