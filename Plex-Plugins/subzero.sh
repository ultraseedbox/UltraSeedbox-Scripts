#!/bin/bash

# Subzero Installer/Updater by Liara#9557 and Xan#7777

plugindir=$HOME/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/

if [ ! -d "$HOME/.config/plex/" ];
then
    echo "Plex is not installed. Exiting..."
    exit
fi

if [[ -d "$plugindir/Sub-Zero.bundle" ]];
then
    echo "Sub-zero found. Upgrading..."
    cd "$plugindir/Sub-Zero.bundle/" || exit
    git pull
    app-plex restart
    sleep 15
    echo "Sub-Zero Upgraded."
    exit
else
    echo "Installing Sub-Zero..."
    cd "$plugindir" || exit
    git clone https://github.com/pannal/Sub-Zero.bundle.git
    app-plex restart
    sleep 15
    echo "Sub-Zero installed."
    exit
fi