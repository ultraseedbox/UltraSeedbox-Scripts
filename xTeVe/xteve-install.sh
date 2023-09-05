#!/bin/bash

# xTeVe installer by Xan#7777
# Installs XTeVe Locally in USB Slot

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
echo "To install multiple intances rerun with unique id, Ex: $0 <ID>"
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
wget https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_amd64.zip
unzip xteve_linux_amd64.zip -d "$HOME"/bin/

# Unused Port Picker
app-ports show

echo "Pick any application from this list that you're not currently using."
echo "We'll be using this port for xTeVe."
echo "For example, you chose SickRage so type in 'sickrage'"
echo "Type in the application below."

read -r appname
proper_app_name=$(app-ports show | grep -i "$appname" | cut -c 7-)
port=$(app-ports show | grep -i "$appname" | cut -b -5)

if [ -n "$1" ]
then
     id=$1
else
     id=""
fi

config_dir="$HOME/.xteve$id"

echo "Are you sure you want to use $proper_app_name's port? type 'confirm' to proceed."
read -r input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Generate config
timeout 10  "$HOME"/bin/xteve -port="$port" -config "$config_dir/"

# Set tmp
sed -i "s|/tmp/xteve|/tmp/$USER/xteve|g" $config_dir/settings.json

# systemd service
export XDG_RUNTIME_DIR=/run/user/"$UID"
echo "[Unit]
Description=xTeve Tuner

[Service]
Type=simple

ExecStart=$HOME/bin/xteve -port=$port -config $config_dir/

[Install]
WantedBy=default.target" > "$HOME/.config/systemd/user/xteve$id.service"

# Start Services
systemctl --user daemon-reload
systemctl --user start xteve$id.service
systemctl --user enable xteve$id.service

echo ""
echo ""
echo "Access xTeVe's Web Interface via http://$HOSTNAME.usbx.me:$port/web"

# Cleanup
rm -rfv "$HOME"/.xteve-tmp
exit
