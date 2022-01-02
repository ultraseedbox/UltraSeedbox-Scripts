#!/bin/bash
set -e

#Install check
if [[ -f "$HOME"/.apps/nginx/proxy.d/qbitdark.conf ]]; then
echo "qBittorrent dark theme already installed. Visit at the following URL:https://$USER.$HOSTNAME.usbx.me/qbittorrent-dark"
exit 0
fi

#Install theme
app-nginx stop
port=$(app-ports show| grep qBittorrent | awk '{print $1}')
wget -P "$HOME/.apps/nginx/proxy.d/" https://raw.githubusercontent.com/raikiri72/UltraSeedbox-Scripts/qbitdarktheme/qBittorrent/qbitdark.conf
sed -i "s/>port</$port/g" "$HOME"/.apps/nginx/proxy.d/qbitdark.conf
app-nginx restart

echo "qBittorrent dark theme installed, visit at following URL:https://$USER.$HOSTNAME.usbx.me/qbittorrent-dark"
exit 0
