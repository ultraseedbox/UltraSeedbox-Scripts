#!/bin/bash

set -e

#Disclaimer
printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

#Port-Picker by XAN & Raikiri
while [ -z "$port" ]
do
  app-ports show
  echo "Pick any application from the list above, that you're not currently using."
  echo "We'll be using this port for your instance of Flaresolverr."
  read -p "$(tput setaf 4)$(tput bold)Application name in full[Example: pyload]: $(tput sgr0)" appname
  proper_app_name=$(app-ports show | grep -i "$appname" | head -n 1 | cut -c 7-)
  port=$(app-ports show | grep -i "$appname" | head -n 1 | awk {'print $1'})
  if [ -z "$port" ]
  then
     echo "$(tput setaf 1)Invalid choice! Please choose an application from the list and avoid typos.$(tput sgr0)"
     echo "$(tput bold)Listing all applications again..$(tput sgr0)"
     sleep 5
     clear
  fi
done
echo "$(tput setaf 2)Are you sure you want to use $proper_app_name's port? type 'confirm' to proceed.$(tput sgr0)"
read -r input
if [ ! "$input" = "confirm" ]
then
  exit
fi

#Choose Flaresolverr version
echo "Choose FlareSolverr version:
1. v2.0.2[Only this works at the moment]
2. Latest"

read -p "Choice [default: 1]: " version

case $version in

  1)
    version="v2.0.2"
    ;;

  2)
    LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/FlareSolverr/FlareSolverr/releases/latest)
    LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    version="$LATEST_VERSION"
    ;;

  *)
    echo -n "Invalid choice. Installing FlareSolverr v2.0.2.."
    version="v2.0.2"
    ;;
esac

url=https://github.com/FlareSolverr/FlareSolverr/releases/download/$version/flaresolverr-$version-linux-x64.zip

#Uninstall Old Version
if [ -d "$HOME"/.flaresolverr ]
then
  rm -rf "$HOME"/.flaresolverr
fi

#Get Binaries
mkdir -p "$HOME"/.tmp
wget -P "$HOME"/.tmp $url
unzip "$HOME"/.tmp/flaresolverr-$version-linux-x64.zip -d "$HOME"/
mv "$HOME"/flaresolverr "$HOME"/.flaresolverr
rm -rf "$HOME"/.tmp

#Install systemd service
echo '[Unit]
Description=FlareSolverr
After=network.target

[Service]
SyslogIdentifier=flaresolverr
Restart=always
RestartSec=5
Type=simple
Environment="LOG_LEVEL=info"
Environment="CAPTCHA_SOLVER=none"
Environment="PORT=>port<"
WorkingDirectory=%h/.flaresolverr
ExecStart=%h/.flaresolverr/flaresolverr
TimeoutStopSec=30
StandardOutput=file:%h/scripts/flaresolverr.log

[Install]
WantedBy=multi-user.target' > "$HOME"/.config/systemd/user/flaresolverr.service

if [ ! -d "$HOME"/scripts ]
then
  mkdir -p "$HOME"/scripts
fi

sed -i "s/>port</$port/g" "$HOME"/.config/systemd/user/flaresolverr.service

systemctl --user daemon-reload
systemctl --user enable --now flaresolverr.service

echo "Flaresolverr is installed on port $port".

exit
