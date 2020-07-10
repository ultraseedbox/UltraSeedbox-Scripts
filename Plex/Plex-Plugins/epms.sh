#!/bin/bash

# EPMS Installer/Updater by Liara#9557 and Xan#7777

plugindir=$HOME/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/
scannerdir=$HOME/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Scanners/Series

if [ ! -d "$HOME/.config/plex/" ];
then
    echo "Plex is not installed. Exiting..."
    exit
fi

if [[ -f "$scannerdir/Extended Personal Media Scanner.py" && -d "$plugindir/extendedpersonalmedia-agent.bundle/" ]];
then
    echo "EPMS found. Upgrading..."
    rm -rf "$scannerdir/Extended Personal Media Scanner.py" 
    wget -O "$scannerdir/Extended Personal Media Scanner.py" https://bitbucket.org/mjarends/plex-scanners/raw/master/Series/Extended%20Personal%20Media%20Scanner.py
    cd "$plugindir/extendedpersonalmedia-agent.bundle/" || exit
    git pull
    echo "Staring PMS..."
    app-plex restart
    sleep 15
    echo "EPMS updated successfully!"
    exit
else
    echo "Installing EPMS..."
    mkdir -p "$scannerdir"
    wget -O "$scannerdir/Extended Personal Media Scanner.py" https://bitbucket.org/mjarends/plex-scanners/raw/master/Series/Extended%20Personal%20Media%20Scanner.py
    cd "$plugindir" || exit
    git clone https://bitbucket.org/mjarends/extendedpersonalmedia-agent.bundle
    echo "Staring PMS..."
    app-plex restart
    sleep 15
    echo "EPMS installed successfully!"
    exit
fi