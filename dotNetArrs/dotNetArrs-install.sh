#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi

#Application Select from https://wiki.servarr.com/install-script

echo "Select the application to install [ Choose from 1 - 5 ]: "

select app in lidarr prowlarr radarr readarr quit; do

  case ${app} in
  lidarr)
    branch="master" # {Update me if needed} branch to install
    break
    ;;
  prowlarr)
    branch="develop" # {Update me if needed} branch to install
    break
    ;;
  radarr)
    branch="master" # {Update me if needed} branch to install
    break
    ;;
  readarr)
    branch="develop" # {Update me if needed} branch to install
    break
    ;;
  quit)
    exit 0
    ;;
  *)
    echo "Invalid option $REPLY"
    ;;
  esac
done

#Port-Picker by XAN & Raikiri

port=''
backup=''
while [ -z "${port}" ]; do
  app-ports show
  echo "Pick any application from the list above, that you're not currently using."
  echo "We'll be using this port for your second instance of ${app^}"
  read -rp "$(tput setaf 4)$(tput bold)Application name in full[Example: pyload]: $(tput sgr0)" appname
  proper_app_name=$(app-ports show | grep -i "${appname}" | head -n 1 | cut -c 7-) || proper_app_name=''
  port=$(app-ports show | grep -i "${appname}" | head -n 1 | awk '{print $1}') || port=''
  if [ -z "${port}" ]; then
    echo "$(tput setaf 1)Invalid choice! Please choose an application from the list and avoid typos.$(tput sgr0)"
    echo "$(tput bold)Listing all applications again..$(tput sgr0)"
    sleep 5
    clear
  fi
done
echo "$(tput setaf 2)Are you sure you want to use ${proper_app_name}'s port? type 'confirm' to proceed.$(tput sgr0)"
read -r input
if [ ! "${input}" = "confirm" ]; then
  exit
fi
echo

#Get password

while true; do
  read -rsp "The password for your second instance of ${app^}: " password
  echo
  read -rsp "The password for your second instance of ${app^} (again): " password2
  echo
  [ "${password}" = "${password2}" ] && break
  echo "Passwords didn't match, try again."
done

#Perform Checks

if [ ! -d "${HOME}/tmp" ]; then
  mkdir -p "${HOME}/tmp"
fi

if systemctl --user is-active --quiet "${app}.service"; then
  systemctl --user stop "${app}.service"
  systemctl --user --quiet disable "${app}.service"
  echo "Stopped existing second ${app^} instance."
fi

if [ -d "${HOME}/.config/${app}2" ]; then
  echo "Re-installing binaries.."
  sleep 2
  rm -rf "${HOME}/.config/${app}2"
fi

if [ -d "${HOME}/.apps/${app}2" ]; then
  backup="${HOME}/.apps/${app}2-$(date +"%FT%H%M").bak"
  mv "${HOME}/.apps/${app}2" "${backup}"
  echo "Installing fresh second instance of ${app^}.."
fi

#Get binaries

mkdir -p "${HOME}"/.config/.temp
wget -qO "${HOME}"/.config/.temp/${app}.tar.gz --content-disposition "http://${app}.servarr.com/v1/update/${branch}/updatefile?os=linux&runtime=netcore&arch=x64"
tar -xvzf "${HOME}"/.config/.temp/${app}.tar.gz -C "${HOME}/.config/.temp" && mv "${HOME}/.config/.temp/${app^}" "${HOME}/.config/${app}2" && rm -rf "${HOME}"/.config/.temp

#Install nginx conf

cat <<EOF | tee "${HOME}/.apps/nginx/proxy.d/${app}2.conf" >/dev/null
location /${app}2 {
  proxy_pass        http://127.0.0.1:${port}/${app}2;
  proxy_set_header Host \$host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host \$host;
  proxy_set_header X-Forwarded-Proto https;
  proxy_redirect off;

  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$http_connection;
}
  location /${app}2/api { auth_request off;
  proxy_pass       http://127.0.0.1:${port}/${app}2/api;
}

  location /${app}2/Content { auth_request off;
    proxy_pass http://127.0.0.1:${port}/${app}2/Content;
}
EOF

#Install Systemd service

cat <<EOF | tee "${HOME}"/.config/systemd/user/${app}.service >/dev/null
[Unit]
Description="${app^}" Daemon
After=network-online.target
[Service]
Environment="TMPDIR=%h/tmp"
Type=simple

ExecStart=%h/.config/${app}2/"${app^}" -nobrowser -data=%h/.apps/${app}2/
TimeoutStopSec=20
KillMode=process
Restart=always
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user --quiet enable --now "${app}".service
sleep 10

#Set port

cat <<EOF | tee "${HOME}/.apps/${app}2/config.xml" >/dev/null
<Config>
  <LogLevel>info</LogLevel>
  <UrlBase>/${app}2</UrlBase>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>${branch}</Branch>
  <Port>$port</Port>
  <AuthenticationMethod>Forms</AuthenticationMethod>
</Config>
EOF

# Create User

systemctl --user stop "${app}".service
username=${USER}
guid=$(python -c 'import uuid; print(str(uuid.uuid4()))')
password_hash=$(echo -n "${password}" | sha256sum | awk '{print $1}')

sqlite3 "${HOME}/.apps/${app}2/${app}.db" <<EOF
INSERT INTO Users (Id, Identifier, Username, Password)
VALUES ( 1, "$guid", "$username", "$password_hash");
EOF

#Perform restarts

systemctl --user restart "${app}".service
app-nginx restart

echo
if [ -n "${backup}" ]; then echo "Configuration data of the previous installation backed up at ${backup}"; fi
echo "Installation complete."
echo "You can access it via the following URL:https://${USER}.${HOSTNAME}.usbx.me/${app}2"
exit