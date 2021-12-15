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
echo "We'll be using this port for your second Readarr instance."
echo "For example, you chose SickChill so type in 'sickchill'. Please type it in full name."
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

#Get Readarr binaries
mkdir -p "$HOME"/.config/.temp; cd $_
wget -O "$HOME"/.config/.temp/readarr.tar.gz --content-disposition 'http://readarr.servarr.com/v1/update/nightly/updatefile?os=linux&runtime=netcore&arch=x64' 
tar -xvf readarr.tar.gz -C "$HOME/.config/" && cd "$HOME"
sleep 5
rm -rf "$HOME"/.config/.temp
mv "$HOME"/.config/Readarr "$HOME"/.config/readarr2

#Install nginx conf
echo 'location ^~ /readarr2 {
    proxy_set_header    Host $host;
    #proxy_set_header    X-Real-IP $remote_addr;
    #proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
    #proxy_set_header    X-Forwarded-Proto $scheme;
    #add_header          X-Frame-Options SAMEORIGIN;

    proxy_pass          http://127.0.0.1:>port<;
    proxy_redirect      off;
    proxy_connect_timeout 300;
    proxy_send_timeout 300;
    proxy_read_timeout 300;

    #access_log logs/readarr.access.log;
    #error_log  logs/readarr.error.log;
}' > "$HOME/.apps/nginx/proxy.d/readarr2.conf"

sed -i "s/>port</$port/g" "$HOME"/.apps/nginx/proxy.d/readarr2.conf

#Install Systemd service
cat << EOF | tee ~/.config/systemd/user/readarr2.service > /dev/null
[Unit]
Description=Readarr2 Daemon
After=network-online.target
[Service]
Type=simple

ExecStart=%h/.config/readarr2/Readarr -nobrowser -data=%h/.apps/readarr2/
TimeoutStopSec=20
KillMode=process
Restart=always
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now readarr2.service
sleep 10

#Set readarr port
echo '<Config>
  <LogLevel>info</LogLevel>
  <UrlBase>/readarr2</UrlBase>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>develop</Branch>
  <Port>temport</Port>
</Config>' > "$HOME/.apps/readarr2/config.xml"

sed -i "s/temport/$port/g" "$HOME"/.apps/readarr2/config.xml

systemctl --user restart readarr2.service
app-nginx restart

echo ""
echo ""
echo "Installation complete."
echo "You can access it via https://$USER.$HOSTNAME.usbx.me/readarr2"
echo "Go to Settings -> General and setup authentication. Form login is recommended."
printf "\033[0;31mPlease do the above after first login!!! Failing to do so will keep your second Readarr instance open to public.\033[0m\n"

exit
