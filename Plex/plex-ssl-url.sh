#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This script is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
    exit
fi
echo

#Checks

if [ ! -f "${HOME}/.config/plex/Library/Application Support/Plex Media Server/Preferences.xml" ]; then
    echo "Preferences.xml file of Plex Media Server not found."
    echo "Please ensure that you have Plex Media Server installed, then run the script again."
    echo
fi

#Get Certificate UUID

uuid=$(grep -o 'CertificateUUID="[a-zA-Z0-9]*"' "${HOME}/.config/plex/Library/Application Support/Plex Media Server/Preferences.xml" | grep -o '".*"' | sed 's/"//g')

#Get IP Address

ip=$(hostname -I | awk '{print $1}' | sed 's/\./-/g')

#Create required URL

url="${ip}.${uuid}.plex.direct"
plexport="$(app-ports show | grep "Plex Media Server" | awk '{print $1}')"

echo "URL to use for an SSL connection to your Plex Media Server: ${url}"
echo "Your Plex Media Server instance's port: ${plexport}"
echo
exit