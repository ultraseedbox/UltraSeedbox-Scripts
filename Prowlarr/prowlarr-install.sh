#!/bin/bash

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

#Port-Picker by XAN
app-ports show
echo "Pick any application from this list that you're not currently using."
echo "We'll be using this port for Prowlarr."
echo "For example, you chose SickRage so type in 'sickrage'. Please type it in full name."
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

#Get Prowlarr binaries
mkdir -p "$HOME"/.config/.temp; cd $_
wget -O "$HOME"/.config/.temp/prowlarr.tar.gz --content-disposition 'http://prowlarr.servarr.com/v1/update/develop/updatefile?os=linux&runtime=netcore&arch=x64' 
tar -xvf prowlarr.tar.gz -C ../ && cd "$HOME"
rm -rf "$HOME"/.config/.temp

#Install nginx conf
echo 'location /prowlarr {
  proxy_pass    http://127.0.0.1:>port</prowlarr;
  proxy_set_header Host              $host;
  proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host  $host;
  proxy_set_header X-Forwarded-Proto https;
  proxy_redirect  off;

  proxy_http_version 1.1;
  proxy_set_header  Upgrade     $http_upgrade;
  proxy_set_header  Connection  $http_connection;
}

location /prowlarr/api {
  auth_request off;
  proxy_pass  http://127.0.0.1:>port</prowlarr/api;
  proxy_set_header Host              $host;
  proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host  $host;
  proxy_set_header X-Forwarded-Proto https;
  proxy_redirect  off;
}

location ~ /prowlarr/[0-9]+/api {
 auth_request off;
  proxy_pass  http://127.0.0.1:>port<;
  proxy_set_header Host              $host;
  proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host  $host;
  proxy_set_header X-Forwarded-Proto https;
  proxy_redirect  off;
}

location /prowlarr/Content {
 auth_request off;
 proxy_pass  http://127.0.0.1:>port</prowlarr/Content;
}' > "$HOME/.apps/nginx/proxy.d/prowlarr.conf"

sed  -i "s/>port</$port/g" "$HOME"/.apps/nginx/proxy.d/prowlarr.conf

#Install Systemd service
cat << EOF | tee ~/.config/systemd/user/prowlarr.service > /dev/null
[Unit]
Description=Prowlarr Daemon
After=network-online.target
[Service]
Type=simple

ExecStart=%h/.config/Prowlarr/Prowlarr -nobrowser -data=%h/.apps/prowlarr/
TimeoutStopSec=20
KillMode=process
Restart=always
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now prowlarr.service
sleep 10

#Set prowlarr port
echo '<Config>
  <LogLevel>info</LogLevel>
  <UrlBase>/prowlarr</UrlBase>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>develop</Branch>
  <Port>temport</Port>
</Config>' > "$HOME/.apps/prowlarr/config.xml"

sed -i "s/temport/$port/g" "$HOME"/.apps/prowlarr/config.xml

systemctl --user restart prowlarr.service
app-nginx restart

echo ""
echo ""
echo "Installation complete."
echo "You can access it via https://$USER.$HOSTNAME.usbx.me/prowlarr"
echo "Go to Settings -> General and setup authentication. Form login is recommended."
printf "\033[0;31mPlease do the above after first login!!! Failing to do so will keep your Prowlarr instance open to public.\033[0m\n"

exit
