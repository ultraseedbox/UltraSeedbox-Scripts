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
status='fresh install'
while [ -z "${port}" ]; do
  app-ports show
  echo "Pick any application from the list above, that you're not currently using."
  echo "We'll be using this port for your second instance of Sonarr"
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
  read -rsp "The password for your second instance of Sonarr: " password
  echo
  read -rsp "The password for your second instance of Sonarr (again): " password2
  echo
  [ "${password}" = "${password2}" ] && break
  echo "Passwords didn't match, try again."
done

#Perform Checks

if [ ! -d "${HOME}/tmp" ]; then
  mkdir -p "${HOME}/tmp"
fi

if [ ! -d "${HOME}/.apps/backup" ]; then
  mkdir -p "${HOME}/.apps/backup"
fi

if systemctl --user is-active --quiet "sonarr.service" || [ -f "${HOME}/.config/systemd/users/sonarr.service" ]; then
  systemctl --user stop "sonarr.service"
  systemctl --user --quiet disable "sonarr.service"
  echo
  echo "Disabled old second Sonarr instance."
fi

if [ -d "${HOME}/.apps/sonarr2" ]; then
  echo
  echo "Old second instance of Sonarr detected. How do you wish to proceed? In the case of a fresh install the current AppData directory will be backed up."

  select status in 'Fresh Install' 'Update' quit; do

    case ${status} in
    'Fresh Install')
      status="fresh install"
      break
      ;;
    'Update')
      status='update'
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
fi

if [ -d "${HOME}/.apps/sonarr2" ] && [ "${status}" == 'fresh install' ]; then
  backup="${HOME}/.apps/backup/sonarr2-$(date +"%FT%H%M").bak.tar.gz"
  echo
  echo "Creating a backup of the current instance's AppData directory.."
  tar -czf "${backup}" -C "${HOME}/.apps/" "sonarr2" && rm -rf "${HOME}/.apps/sonarr2"
  echo
  echo "Installing fresh second instance of Sonarr.."
fi

if [ -d "${HOME}/.config/sonarr2" ]; then
  echo
  echo "Removing old binaries.."
  sleep 2
  rm -rf "${HOME}/.config/sonarr2"
fi

#Get binaries

echo
echo "Pulling new binaries.."
mkdir -p "${HOME}"/.config/.temp
wget -qO "${HOME}"/.config/.temp/sonarr.tar.gz --content-disposition "https://services.sonarr.tv/v1/download/main/latest?version=3&os=linux"
tar -xzf "${HOME}"/.config/.temp/sonarr.tar.gz -C "${HOME}/.config/.temp" && mv "${HOME}/.config/.temp/Sonarr" "${HOME}/.config/sonarr2" && rm -rf "${HOME}"/.config/.temp

#Install nginx conf

cat <<EOF | tee "${HOME}/.apps/nginx/proxy.d/sonarr2.conf" >/dev/null
location /sonarr2 {
  proxy_pass         http://127.0.0.1:${port}/sonarr2;
  proxy_set_header   Host \$host;
  proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header   X-Forwarded-Host \$host;
  proxy_set_header   X-Forwarded-Proto \$scheme;
  proxy_redirect     off;
  proxy_http_version 1.1;
  proxy_set_header   Upgrade \$http_upgrade;
  proxy_set_header   Connection \$http_connection;
}
# Allow the API External Access via NGINX
location ~ /sonarr2/api {
    auth_request      off;
    proxy_pass        http://127.0.0.1:${port};
}
EOF

#Install Systemd service

cat <<EOF | tee "${HOME}"/.config/systemd/user/sonarr.service >/dev/null
[Unit]
Description=Sonarr Daemon
After=network-online.target
[Service]
Environment="TMPDIR=%h/tmp"
Type=simple
ExecStart=/usr/bin/mono --debug %h/.config/sonarr2/Sonarr.exe -nobrowser -data=%h/.apps/sonarr2/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=default.target
EOF

#Set port

if [ ! -d "${HOME}/.apps/sonarr2" ]; then
  mkdir -p "${HOME}/.apps/sonarr2"
fi

cat <<EOF | tee "${HOME}/.apps/sonarr2/config.xml" >/dev/null
<Config>
  <LogLevel>info</LogLevel>
  <UrlBase>/sonarr2</UrlBase>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>main</Branch>
  <Port>${port}</Port>
  <AuthenticationMethod>Forms</AuthenticationMethod>
</Config>
EOF

#Start systemd service

echo "Starting Sonarr..(this will take a minute)"
systemctl --user daemon-reload
systemctl --user --quiet enable --now "sonarr".service
sleep 30

## Wait for DB

if systemctl --user is-active --quiet "sonarr.service"; then
  while [ ! -f "${HOME}/.apps/sonarr2/sonarr.db" ]; do
    sleep 5
  done
fi

if ! systemctl --user is-active --quiet "sonarr.service"; then
  echo "Initial instance of Sonarr failed to start properly, install aborted. Please check port selection, HDD IO and other resource utilization."
  exit 1
fi

systemctl --user stop "sonarr".service

# Create/Update User

if ! sqlite3 "${HOME}/.apps/sonarr2/sonarr.db" ".tables" | grep -q "Users"; then
  echo "Initial sonarr.db is corrupted. Install aborted. Please check HDD IO and other resource utilization."
  exit 1
fi

username=${USER}
guid=$(python -c 'import uuid; print(str(uuid.uuid4()))')
password_hash=$(echo -n "${password}" | sha256sum | awk '{print $1}')

if [ "${status}" == 'fresh install' ]; then
  sqlite3 "${HOME}/.apps/sonarr2/sonarr.db" <<EOF
INSERT INTO Users (Id, Identifier, Username, Password)
VALUES ( 1, "$guid", "$username", "$password_hash");
EOF
elif [ "${status}" == 'update' ]; then
  sqlite3 "${HOME}/.apps/sonarr2/sonarr.db" <<EOF
UPDATE Users
SET Password = "$password_hash"
EOF
fi

#Perform restarts

systemctl --user restart "sonarr".service
sleep 10
app-nginx restart

#Relay information about backup

echo
if [ -n "${backup}" ]; then
  echo "AppData directory of the previous installation backed up at ${backup}"
  echo
fi

#Ensure that application is running

x=1
while [ ${x} -le 4 ]; do
  if systemctl --user is-active --quiet "sonarr.service"; then
    echo "${status^} complete."
    echo "You can access the second instance of Sonarr via the following URL:https://${USER}.${HOSTNAME}.usbx.me/sonarr2"
    exit
  else
    if [ ${x} -ge 4 ]; then
      echo "Sonarr failed to start. Try re-running the script and choose a different application's port."
      echo "It has to be an application that you do not plan to use at all."
      exit
    fi
    echo "Sonarr failed to start."
    echo
    echo "Restarting Sonarr ${x}/3 times.."
    echo
    systemctl --user restart "sonarr.service"
    sleep 10
    x=$(("${x}" + 1))
  fi
done