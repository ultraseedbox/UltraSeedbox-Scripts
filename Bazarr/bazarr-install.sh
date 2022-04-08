#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi

#Port-Picker by XAN & Raikiri

port=''
backup=''
while [ -z "${port}" ]; do
  app-ports show
  echo "Pick any application from the list above, that you're not currently using."
  echo "We'll be using this port for your second instance of Bazarr."
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
  read -rsp "The password for your second instance of Bazarr: " password
  echo
  read -rsp "The password for your second instance of Bazarr (again): " password2
  echo
  [ "${password}" = "${password2}" ] && break
  echo "Passwords didn't match, try again."
done
password_hash=$(echo -n "${password}" | md5sum | awk '{print $1}')

#Perform Checks

if [ ! -d "${HOME}/.apps/backup" ]; then
  mkdir -p "${HOME}/.apps/backup"
fi

if systemctl --user is-active --quiet "bazarr.service"; then
  systemctl --user stop "bazarr.service"
  systemctl --user --quiet disable "bazarr.service"
  echo
  echo "Stopped the existing second instance of Bazarr."
  sleep 5
fi

if [ -d "${HOME}/.apps/bazarr2" ]; then
  backup="${HOME}/.apps/bazarr2-$(date +"%FT%H%M").bak"
  mv "${HOME}/.apps/bazarr2" "${backup}"
  echo
  echo "Updating second instance of Bazarr.."
  echo
  sleep 5
fi

#Get Binaries

mkdir -p "${HOME}/.config/.temp"
mkdir -p "${HOME}/.apps/bazarr2"
wget -qO "${HOME}/.config/.temp/bazarr.zip" --content-disposition "https://github.com/morpheus65535/bazarr/releases/latest/download/bazarr.zip"
unzip "${HOME}/.config/.temp/bazarr.zip" -d "${HOME}/.apps/bazarr2" && rm -rf "${HOME}"/.config/.temp
clear

if [ -n "${backup}" ]; then
  cp -r "${backup}/data" "${HOME}/.apps/bazarr2/"
  base="$(basename "${backup}")"
  tar -czf "${HOME}/.apps/backup/${base}.tar.gz" -C "${HOME}/.apps/" "${base}/data" && rm -rf "${HOME}/.apps/${base}"
fi

#Install Requirements

/usr/bin/python3 -m pip install -q -r "${HOME}/.apps/bazarr2/requirements.txt"

#Install Nginx conf

cat <<EOF | tee "${HOME}/.apps/nginx/proxy.d/bazarr2.conf" >/dev/null
location /bazarr2/ {
   proxy_pass              http://127.0.0.1:${port}/bazarr2/;
   proxy_set_header        X-Real-IP               \$remote_addr;
   proxy_set_header        Host                    \$http_host;
   proxy_set_header        X-Forwarded-For         \$proxy_add_x_forwarded_for;
   proxy_set_header        X-Forwarded-Proto       \$scheme;
   proxy_http_version      1.1;
   proxy_set_header        Upgrade                 \$http_upgrade;
   proxy_set_header        Connection              "Upgrade";
   proxy_redirect off;
}
EOF

#Install systemd service

cat <<EOF | tee "${HOME}"/.config/systemd/user/bazarr.service >/dev/null
[Unit]
Description=Bazarr Daemon
After=network.target

[Service]
WorkingDirectory=%h/.apps/bazarr2
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=/usr/bin/python3 %h/.apps/bazarr2/bazarr.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=bazarr
ExecStartPre=/bin/sleep 10

[Install]
WantedBy=default.target
EOF

echo "Starting Bazarr..(this will take a minute)"
systemctl --user daemon-reload
systemctl --user --quiet enable --now "bazarr.service"
sleep 20
systemctl --user stop "bazarr.service"
sleep 5

#Set config.ini

config="${HOME}/.apps/bazarr2/data/config/config.ini"

if [ ! -f "${config}" ]; then
  echo "Initial Bazarr configuration file missing. Install aborted. Please check HDD IO utilization and port that you selected."
  exit 1
fi

sed -i '/^\[general\]$/,/^\[/ s/ip = .*/ip = 127.0.0.1/g' "${config}"
sed -i "/^\[general\]$/,/^\[/ s/port = .*/port = ${port}/g" "${config}"
sed -i '/^\[general\]$/,/^\[/ s/base_url = .*/base_url = \/bazarr2/g' "${config}"
sed -i '/^\[auth\]$/,/^\[/ s/type = .*/type = form/g' "${config}"
sed -i "/^\[auth\]$/,/^\[/ s/username = .*/username = ${USER}/g" "${config}"
sed -i "/^\[auth\]$/,/^\[/ s/password = .*/password = ${password_hash}/g" "${config}"

#Perform restarts

systemctl --user restart "bazarr.service"
sleep 20
app-nginx restart

#Relay information about backup

process="Installation"
echo
if [ -n "${backup}" ]; then
  echo "Data of the previous installation backed up at ${HOME}/.apps/backup/${base}.tar.gz"
  process="Update"
  echo
fi

#Ensure that application is running

x=1
while [ ${x} -le 4 ]; do
  if systemctl --user is-active --quiet "bazarr.service"; then
    echo "${process} complete."
    echo "You can access the second instance of Bazarr via the following URL:https://${USER}.${HOSTNAME}.usbx.me/bazarr2"
    exit
  else
    if [ ${x} -ge 4 ]; then
      echo "Bazarr failed to start. Try re-running the script and choose a different application's port."
      echo "It has to be an application that you do not plan to use at all."
      exit
    fi
    echo "Bazarr failed to start."
    echo
    echo "Restarting Bazarr ${x}/3 times.."
    echo
    systemctl --user restart "bazarr.service"
    x=$(("${x}" + 1))
  fi
done