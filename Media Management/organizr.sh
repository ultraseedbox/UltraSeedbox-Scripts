#!/bin/bash

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it.\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

#Install Organizr
git clone https://github.com/causefx/Organizr.git ~/www/organizr

#Install nginx conf
echo 'location /organizr/api/v2 {
  try_files $uri /organizr/api/v2/index.php$is_args$args;
  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host $host;
  proxy_set_header X-Forwarded-Proto https;
  proxy_redirect off;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $http_connection;
}' > "$HOME/.apps/nginx/proxy.d/organizr.conf"

#Restart Nginx
app-nginx restart

echo ""
echo ""
echo ""
echo "You should now proceed to access Organizr via https://$USER.$HOSTNAME.usbx.me/organizr"
echo "You will need to use your HTTP access credentials"
