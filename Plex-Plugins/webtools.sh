#!/bin/bash

# Webtools Installer/Updater by Liara#9557 and Xan#7777

plugindir=$HOME/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-ins/
supportdir=$HOME/.config/plex/Library/Application\ Support/Plex\ Media\ Server/Plug-in\ Support/

if [ ! -d "$HOME/.config/plex/" ];
then
    echo "Plex is not installed. Exiting..."
    exit
fi

if [ -d "$plugindir/WebTools.bundle" ];
then
  echo "Webtools Found. Upgrading..."
  cd "$plugindir/WebTools.bundle/" || exit
  git pull
  rm -rf "$supportdir/Caches/com.plexapp.plugins.WebTools"
  rm -rf "$supportdir/Data/com.plexapp.plugins.WebTools"
  rm -rf "$supportdir/Preferences/com.plexapp.plugins.WebTools.xml"
  app-plex restart
  sleep 15
  echo "Webtools Upgraded."
  rm -- "$0"
  exit
else
  echo "Installing WebTools..."
  cd "$plugindir" || exit
  git clone https://github.com/ukdtom/WebTools.bundle.git
  app-plex restart
  sleep 15
  echo "Webtools installed."
  rm -- "$0"
  exit
fi