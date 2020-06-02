#!/bin/bash

# Trakt.tv Scrobbler Installer by Liara#9557 and Xan#7777

plugindir=$HOME/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/

if [ ! -d "$HOME/.config/plex/" ];
then
    echo "Plex is not installed. Exiting..."
    exit
else
    echo "Installing Trakt.tv Scrobbler..."
    cd "$HOME" || exit
    git clone --depth 1 https://github.com/trakt/Plex-Trakt-Scrobbler.git
    cd Plex-Trakt-Scrobbler || exit
    cp -a Trakttv.bundle "$plugindir"
    cd "$HOME" || exit
    rm -rf Plex-Trakt-Scrobbler
    app-plex restart
    sleep 15
    echo "Trakt.tv Scrobbler installed!"
    rm -- "$0"
    exit
fi