#!/bin/bash

# Rclone VFS/MergerFS Installer/Updater Script by Xan#7777
# With RC. Use with caution

clear

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

clear

echo "Creating necessary folders..."
    mkdir -p "$HOME"/Stuff
    mkdir -p "$HOME"/Stuff/Local
    mkdir -p "$HOME"/Stuff/Mount
    mkdir -p "$HOME"/MergerFS
    mkdir -p "$HOME"/.config/systemd/user
    mkdir -p "$HOME"/.rclone-tmp
    mkdir -p "$HOME"/.mergerfs-tmp

echo "Stopping service files..."
    systemctl --user disable --now mergerfs.service
    systemctl --user disable --now rclone-vfs.service
    systemctl --user disable --now rclone-normal.service

echo "Killing all rclone/mergerfs instances..."
    killall rclone
    killall mergerfs

echo "Removing service files and old binaries for upgrade..."
    rm "$HOME"/.config/systemd/user/rclone*
    rm "$HOME"/.config/systemd/user/mergerfs*
    rm "$HOME"/bin/rclone*
    rm "$HOME"/bin/mergerfs*
    rm "$HOME"/scripts/rclone*
    rm -rfv "$HOME"/.rclone-tmp/*
    rm -rfv "$HOME"/.mergerfs-tmp/*

echo "Setting XDG_RUNTIME_DIR"
    export XDG_RUNTIME_DIR=/run/user/"$UID"

clear

echo "Installing rclone..."
    sleep 2
    cd "$HOME"/.rclone-tmp || exit
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O "$HOME"/.rclone-tmp/rclone.zip
    unzip rclone.zip
    cp "$HOME"/.rclone-tmp/rclone-v*/rclone "$HOME"/bin
    command -v rclone
    rclone version
echo ""

echo "Installing mergerfs..."
    sleep 2
    cd "$HOME"/.mergerfs-tmp || exit
    wget https://github.com/trapexit/mergerfs/releases/download/2.28.3/mergerfs_2.28.3.debian-stretch_amd64.deb -O "$HOME"/.mergerfs-tmp/mergerfs.deb
    dpkg -x "$HOME"/.mergerfs-tmp/mergerfs.deb "$HOME"/.mergerfs-tmp
    mv "$HOME"/.mergerfs-tmp/usr/bin/* "$HOME"/bin
    command -v mergerfs
    mergerfs -v

clear

echo "Please set up your rclone config now. During this time, rclone config will be executed."
echo ""
echo "Please setup/check your remotes before continuing."
echo ""
echo "Refer to the following sites for help on this."
echo "=========================================================================="
echo "https://rclone.org/commands/rclone_config/"
echo "https://docs.usbx.me/books/rclone/page/configuring-oauth-for-google-drive"
echo "==========================================================================="
echo ""
echo "Also take note of your remote name."
echo "If you already set it up, you can safely quit config."
    sleep 5
    clear
    rclone config
    wait

clear

echo "Name of remote? Type below and press Enter."
echo "Make sure it's the correct remote name or setup will fail."
    read -r remotename
    sleep 2
    echo ""
    echo ""
    echo "Your remote name is $remotename."
    echo "This will be appended to your rclone mount service files."
    echo ""

clear

# Port Picker
clear
app-ports show

echo "Pick any application from this list that you're not currently using."
echo "We'll be using this port for The Lounge."
echo "For example, you chose SickRage so type in 'sickrage'. Please type it in full name."
echo "Type in the application below."
read -r appname

proper_app_name=$(app-ports show | grep -i "$appname" | cut -c 7-)
port=$(app-ports show | grep -i "$appname" | cut -b -5)

echo "Are you sure you want to use $proper_app_name's port? type 'confirm' to proceed."
read -r input

if [ ! "$input" = "confirm" ]
then
    exit
fi

echo "Done. Downloading service files..."
    sleep 2
    cd "$HOME"/.config/systemd/user || exit
    wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/rclone-vfs/MergerFS-Rclone/Service%20Files/rclone-vfs.service
    wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/rclone-vfs/MergerFS-Rclone/Service%20Files/mergerfs.service
    sed -i "s|/homexx/yyyyy|$HOME|g" "$HOME"/.config/systemd/user/rclone-vfs.service
    sed -i "s|gdrive:|$remotename:|g" "$HOME"/.config/systemd/user/rclone-vfs.service
    sed -i "s|zzzzz|$port|g" "$HOME"/.config/systemd/user/rclone-vfs.service
    sed -i "s|/homexx/yyyyy|$HOME|g" "$HOME"/.config/systemd/user/mergerfs.service

echo "Installing systemd uploader..."
    sleep 2
    wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/rclone-vfs/MergerFS-Rclone/Upload%20Scripts/rclone-uploader.service
    wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/rclone-vfs/MergerFS-Rclone/Upload%20Scripts/rclone-uploader.timer
    sed -i "s#/homexx/yyyyy#$HOME#g" "$HOME"/.config/systemd/user/rclone-uploader.service
    sed -i "s#gdrive:#$remotename:#g" "$HOME"/.config/systemd/user/rclone-uploader.service
    sed -i "s|zzzzz|$port|g" "$HOME"/.config/systemd/user/rclone-uploader.service

echo "Adding Aliases..."
    sleep 2
    touch "$HOME"/.bash_aliases
    echo "alias vfs-refresh='$HOME/bin/rclone rc vfs/refresh --rc-addr=127.0.0.1:zzzzz'" >> "$HOME"/.bash_aliases
    echo "alias vfs-forget='$HOME/bin/rclone rc vfs/forget --rc-addr=127.0.0.1:zzzzz'" >> "$HOME"/.bash_aliases
    sed -i "s|zzzzz|$port|g" "$HOME"/.bash_aliases

clear

echo "Starting services..."
    sleep 2
    systemctl --user daemon-reload
    systemctl --user enable --now rclone-vfs.service
    systemctl --user enable --now mergerfs.service
    systemctl --user enable --now rclone-uploader.service
    systemctl --user enable --now rclone-uploader.timer

echo "Checking if rclone/mergerfs mounts are working..."
    if [ -z "$(ls -A "$HOME"/Stuff/Local)" ]; then
        echo "Local Folder Empty. Continuing..."
        sleep 5
    else
        echo "Script detected that Local folder is not empty. Maybe you have some files here that's not yet been moved or you're using hardlinking."
        echo "Setup will continue..."
        sleep 5
    fi
    if [ -z "$(ls -A "$HOME"/Stuff/Mount)" ]; then
        echo "Mount Folder is empty. Checking your rclone config..."
        sleep 3
        if rclone lsd "$remotename": | grep "Failed"; then
            echo "Mount successful but it's empty. Setup will continue..."
        else
            echo "Configuration error. You may have entered your remote name incorrectly or you forgot to set your rclone config."
            echo "Run this script again to set it up."
            exit
        fi
    else
        echo "Mount Folder is mounted successfully. Continuing..."
        sleep 5
    fi
    cd "$HOME"/MergerFS || exit
    touch test
    echo "MergerFS Test 1 Started..."
    if [ -f "$HOME"/MergerFS/test ] && [ -f "$HOME"/Stuff/Local/test ] && [ ! -f "$HOME"/Stuff/Mount/test ]; then
        echo "MergerFS Test 1 ended successfully."
        echo "Continuing setup..."
        sleep 5
    else
        echo "MergerFS Test 1 is not successful."
        echo "Run the script again."
        exit
    fi
    echo "MergerFS Test 2 Starting..."
    rclone move "$HOME"/Stuff/Local/test "$remotename": -vvv
    sleep 30
        if [ -f "$HOME"/MergerFS/test ] && [ ! -f "$HOME"/Stuff/Local/test ] && [ -f "$HOME"/Stuff/Mount/test ]; then
        echo "MergerFS Test 2 ended successfully."
        echo "Continuing setup..."
        sleep 5
    else
        echo "MergerFS Test 2 not successful."
        echo "Run the script again."
        exit
    fi

echo "Cleaning up..."
    sleep 2
    rclone delete "$remotename":test
    rm -rfv "$HOME"/.rclone-tmp
    rm -rfv "$HOME"/.mergerfs-tmp

clear
echo "Done. Run exec $SHELL to complete installation."
cd "$HOME" || exit
rm -- "$0"
exit