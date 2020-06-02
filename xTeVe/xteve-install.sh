#!/bin/bash

# xTeVe installer by Xan#7777
# Installs XTeVe Locally in USB Slot

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
     exit
fi

# Create Folders
mkdir -p "$HOME"/bin
mkdir -p "$HOME"/.xteve-tmp

# xTeve Extract
cd "$HOME"/.xteve-tmp || exit
wget https://xteve.de/download/xteve_2_linux_amd64.zip
unzip xteve_2_linux_amd64.zip -d "$HOME"/bin/

# Unused Port Picker
app-ports show

echo "Pick any application from this list that you're not currently using."
echo "We'll be using this port for xTeVe."
echo "For example, you chose SickRage so type in 'sickrage'"
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

# Generate config
timeout 10  "$HOME"/bin/xteve -port="$port"

# Set tmp
sed -i "s|/tmp/xteve|/tmp/$USER/xteve|g" "$HOME"/.xteve/settings.json

# systemd service

echo "[Unit]
Description=xTeve Tuner

[Service]
Type=simple

ExecStart=$HOME/bin/xteve -port="$port"

[Install]
WantedBy=default.target" > "$HOME/.config/systemd/user/xteve.service"

# Start Services
systemctl --user daemon-reload
systemctl --user start xteve.service
systemctl --user enable xteve.service

echo ""
echo ""
echo "Access xTeVe's Web Interface via http://$HOSTNAME.usbx.me:$port/web"

# Cleanup
rm -rfv "$HOME"/.xteve-tmp
rm -- "$0"
exit