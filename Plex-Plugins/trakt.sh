#!/bin/bash

plugindir=~/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/

if [ ! -d "$HOME/.config/plex/" ];
then
    echo "Plex is not installed. Exiting..."
    exit
fi

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
exit