#!/bin/bash

# rclone stable Installer/Updater by Xan#7777

if pgrep "rclone";
then
    echo "Rclone is running. Please close all rclone instances before proceeding."
    exit
else
    echo "Installing/Upgrading rclone stable..."
    mkdir -p "$HOME"/.rclone-tmp
    cd "$HOME"/.rclone-tmp || exit
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O "$HOME"/.rclone-tmp/rclone.zip
    unzip rclone.zip
    cp "$HOME"/.rclone-tmp/rclone-v*/rclone "$HOME"/bin
    cd "$HOME" || exit
    rm -rf "$HOME"/.rclone-tmp
    command -v rclone
    rclone version
fi
exit