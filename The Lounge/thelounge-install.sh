#!/bin/bash

# The Lounge Installer by Xan#7777
# Quick and dirty way to install The Lounge to USB Slot
# Install NVM and Node using the following command

# curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash && source .bashrc && nvm install node

# Uninstall ZNC before installing. This needs your slot's ZNC port to work.


# Set Variables
port=$(app-ports show | grep ZNC | cut -b -5)


# Install The Lounge
npm install --global --unsafe-perm thelounge

# Test The Lounge
timeout 5 thelounge start

# Sed ZNC Port
sed  -i "s/port: 9000,/port: $port,/g" "$HOME"/.thelounge/config.js

# Set NGINX conf
echo 'location ^~ /thelounge/ {
    proxy_pass http://127.0.0.1:>port</;
    proxy_redirect      off;
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_read_timeout 300;
    proxy_set_header Connection "upgrade";
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header X-Forwarded-For $remote_addr;
    proxy_set_header X-Forwarded-Proto $scheme;
}' > "$HOME/.apps/nginx/proxy.d/thelounge.conf"

sed  -i "s/>port</$port/g" "$HOME"/.apps/nginx/proxy.d/thelounge.conf

# Set reverseProxy on conf

sed  -i "s/reverseProxy: false,/reverseProxy: true,/g" "$HOME"/.thelounge/config.js

app-nginx restart

# Systemd service

echo "[Unit]
Description=The Lounge

[Service]
Type=simple

WorkingDirectory=$NVM_DIR/versions/node/v14.2.0
ExecStart=$(command -v node) bin/thelounge start

[Install]
WantedBy=default.target" > "$HOME/.config/systemd/user/thelounge.service"

systemctl --user daemon-reload
systemctl --user start thelounge.service
systemctl --user enable thelounge.service

echo ""
echo ""
echo "Installation complete."
echo "You can access it via https://$USER.$HOSTNAME.usbx.me/thelounge"
echo "Run the command below to add username before accessing The Lounge"
echo ""
echo "============================="
echo "thelounge add <name>"
echo "============================="

exit