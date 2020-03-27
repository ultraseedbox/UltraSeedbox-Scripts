#!/bin/bash
#USB Flood installer
#Written by nostyle#0001
#Fixed by Alpha#5000

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
        exit
fi

PORT=$(( 11000 + (($UID - 1000) * 50) + 9))
SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

if [ ! -d "$HOME/.nvm" ]
then
    echo "Installing Node..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install 12 --latest-npm
    nvm alias default 12
    nvm use default
else
    echo "Node already installed. Skipping..."
fi

echo "Installing Flood..."
git clone https://github.com/Flood-UI/flood.git ~/.apps/flood

echo "Configuring Flood..."
cd ~/.apps/flood
cp config.template.js config.js
sed -i "s/floodServerPort: 3000/floodServerPort: $PORT/" config.js
sed -i "s/baseURI: '\/'/baseURI: '\/flood'/" config.js
sed -i "s/secret: 'flood'/secret: '$SECRET'/" config.js
npm install --loglevel=silent
npm run build

echo "Updating nginx..."
echo "location /flood/ {
  proxy_pass http://127.0.0.1:$PORT/;
}" >> ~/.apps/nginx/proxy.d/flood.conf
chmod 755 ~/.apps/nginx/proxy.d/flood.conf
app-nginx restart

echo "Installing Service..."
echo "[Unit]
Description=Flood
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=on-failure
RestartSec=10
WorkingDirectory=$HOME/.apps/flood
ExecStart=$(which node) $HOME/.apps/flood/server/bin/start.js

[Install]
WantedBy=default.target" >> ~/.config/systemd/user/flood.service
systemctl --user daemon-reload
systemctl --user enable flood

loginctl enable-linger $USER

echo "Starting Flood..."
systemctl --user start flood

echo "Downloading Uninstaller..."
cd ~
wget -q https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/Flood/flood-uninstall.sh
chmod +x flood-uninstall.sh

echo "Cleaning Up..."
rm -- "$0"

printf "\033[0;32mDone!\033[0m\n"
echo "Access your Flood installation at https://$USER.$(hostname).usbx.me/flood/"
echo "Use \"$HOME/.config/rtorrent/socket\" for rTorrent Socket"
echo "Run ./flood-uninstall.sh to uninstall"
