#!/bin/bash

if pgrep "rclone";
then
    echo "Rclone is running. Please close all rclone instances before proceeding."
    exit
else
    echo "Installing/Upgrading rclone beta..."
    mkdir -p "$HOME"/.rclone-tmp
    cd "$HOME"/.rclone-tmp || exit
    wget -O rclone-beta-latest-linux-amd64.zip https://beta.rclone.org/rclone-beta-latest-linux-amd64.zip
    unzip rclone-beta-latest-linux-amd64.zip
    cp rclone-v*/rclone "$HOME"/bin
    cd "$HOME" || exit
    rm -rf "$HOME"/.rclone-tmp
    echo "Done."
    command -v rclone
    rclone version
fi