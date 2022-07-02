#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi

cd "${HOME}" || exit 1

clear

#Application Select from https://wiki.servarr.com/install-script

echo "Select the application to install [ Choose from 1 - 5 ]: "

select app in lidarr prowlarr radarr readarr whisparr quit; do

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
  whisparr)
    branch="nightly" # {Update me if needed} branch to install
    break
    ;;
  quit)
    exit 0
    ;;
  *)
    echo "Invalid option ${REPLY}."
    ;;
  esac
done

#Functions

port_picker() {
  port=''
  while [ -z "${port}" ]; do
    app-ports show
    echo "Pick any application from the list above, that you're not currently using."
    echo "We'll be using this port for the second instance of ${app^}."
    read -rp "$(tput setaf 4)$(tput bold)Application name in full[Example: pyload]: $(tput sgr0)" appname
    proper_app_name=$(app-ports show | grep -i "${appname}" | head -n 1 | cut -c 7-) || proper_app_name=''
    port=$(app-ports show | grep -i "${appname}" | head -n 1 | awk '{print $1}') || port=''
    if [ -z "${port}" ]; then
      echo "$(tput setaf 1)Invalid choice! Please choose an application from the list and avoid typos.$(tput sgr0)"
      echo "$(tput bold)Listing all applications again..$(tput sgr0)"
      sleep 10
      clear
    fi
    if netstat -ntpl | grep -q "${port}"; then
      echo "$(tput setaf 1)Port ${port} is already in use by ${proper_app_name}.$(tput sgr0)"
      port=''
      echo "$(tput setaf 1)Please choose another application from the list.$(tput sgr0)"
      echo "$(tput bold)Listing all applications again..$(tput sgr0)"
      sleep 10
      clear
    fi
  done
  echo "$(tput setaf 2)Are you sure you want to use ${proper_app_name}'s port? type 'confirm' to proceed.$(tput sgr0)"
  read -r input
  if [ ! "${input}" = "confirm" ]; then
    exit
  fi
  echo
}

required_paths() {
  declare -a paths
  paths[1]="${HOME}/.apps/${app}2"
  paths[2]="${HOME}/.config/systemd/user"
  paths[3]="${HOME}/.apps/nginx/proxy.d"
  paths[4]="${HOME}/bin"
  paths[5]="${HOME}/.apps/backup"
  paths[6]="${HOME}/.tmp"

  for i in {1..6}; do
    if [ ! -d "${paths[${i}]}" ]; then
      mkdir -p "${paths[${i}]}"
    fi
  done
}

get_password() {
  while true; do
    read -rsp "The password for your second instance of ${app^}: " password
    echo
    read -rsp "The password for your second instance of ${app^} (again): " password2
    echo
    [ "${password}" = "${password2}" ] && break
    echo "Passwords didn't match, try again."
  done
}

get_binaries() {
  rm -rf "${HOME}/.config/${app}2"
  echo
  echo -n "Pulling new binaries.."
  mkdir -p "${HOME}"/.config/.temp
  wget -qO "${HOME}"/.config/.temp/${app}.tar.gz --content-disposition "http://${app}.servarr.com/v1/update/${branch}/updatefile?os=linux&runtime=netcore&arch=x64"
  tar -xzf "${HOME}"/.config/.temp/${app}.tar.gz -C "${HOME}/.config/.temp" && mv "${HOME}/.config/.temp/${app^}" "${HOME}/.config/${app}2" && rm -rf "${HOME}"/.config/.temp
  echo -n "done."
}

nginx_conf_install() {
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

  app-nginx restart
}

systemd_service_install() {
  cat <<EOF | tee "${HOME}"/.config/systemd/user/${app}.service >/dev/null
[Unit]
Description=${app^} Daemon
After=network-online.target
[Service]
Environment="TMPDIR=%h/.tmp"
PrivateTmp=true
Type=simple

ExecStart=%h/.config/${app}2/${app^} -nobrowser -data=%h/.apps/${app}2/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=default.target
EOF

  systemctl --user daemon-reload
}

create_arr_config() {
  cat <<EOF | tee "${HOME}/.apps/${app}2/config.xml" >/dev/null
<Config>
  <LogLevel>info</LogLevel>
  <UrlBase>/${app}2</UrlBase>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>${branch}</Branch>
  <Port>${port}</Port>
  <AuthenticationMethod>Forms</AuthenticationMethod>
  <BindAddress>127.0.0.1</BindAddress>
</Config>
EOF
}

update_arr_config() {
  if [ ! -f "${HOME}/.apps/${app}2/config.xml" ] || [ -z "$(cat "${HOME}/.apps/${app}2/config.xml")" ]; then
    echo
    echo "ERROR: ${app^}2's config.xml does not exist or is empty."
    echo "Do you wish to create a fresh new config.xml?"
    echo
    select yn in "Yes" "No"; do
      case $yn in
      Yes)
        create_arr_config && echo "New config.xml created."
        break
        ;;
      No) echo "Update & Repair failed." && exit 1 ;;
      esac
    done
  fi

  sed -i "s+<Port>.*</Port>+<Port>${port}</Port>+g" "${HOME}/.apps/${app}2/config.xml"
  sed -i "s+<UrlBase>.*</UrlBase>+<UrlBase>/${app}2</UrlBase>+g" "${HOME}/.apps/${app}2/config.xml"
  sed -i "s+<BindAddress>.*</BindAddress>+<BindAddress>127.0.0.1</BindAddress>+g" "${HOME}/.apps/${app}2/config.xml"
}

create_arr_user() {

  if ! systemctl --user is-active --quiet "${app}.service"; then
    echo "Initial instance of ${app^} failed to start properly, install aborted. Please check port selection, HDD IO and other resource utilization."
    echo "Then run the script again and choose Fresh Install."
    exit 1
  fi

  count=1
  while systemctl --user is-active --quiet "${app}.service" && [ ! -f "${HOME}/.apps/${app}2/${app}.db" ] && ${count} -le 6; do
    if [ ${count} -ge 6 ]; then
      echo "Failed to create sqlite database, install aborted. Please check port selection, HDD IO and other resource utilization."
      echo "Then run the script again and choose Fresh Install."
      exit 1
    fi
    sleep 5
    count=$(("${count}" + 1))
  done

  if ! sqlite3 "${HOME}/.apps/${app}2/${app}.db" ".tables" | grep -q "Users"; then
    echo "Initial ${app}.db is corrupted. Install aborted. Please check HDD IO and other resource utilization."
    echo "Then run the script again and choose Fresh Install."
    exit 1
  fi

  systemctl --user stop "${app}.service"

  username=${USER}
  guid=$(cat /proc/sys/kernel/random/uuid)
  password_hash=$(echo -n "${password}" | sha256sum | awk '{print $1}')

  sqlite3 "${HOME}/.apps/${app}2/${app}.db" <<EOF
INSERT INTO Users (Id, Identifier, Username, Password)
VALUES ( 1, "$guid", "$username", "$password_hash");
EOF

  systemctl --user restart "${app}.service"

}

update_arr_user() {
  password_hash=$(echo -n "${password}" | sha256sum | awk '{print $1}')
  sqlite3 "${HOME}/.apps/${app}2/${app}.db" <<EOF
UPDATE Users
SET Password = "$password_hash";
EOF
}

create_backup() {
  backup="${HOME}/.apps/backup/${app}2-$(date +%Y-%m-%d_%H-%M-%S).bak.tar.gz"
  echo
  echo "Creating a backup of the AppData directory.."
  tar -czf "${backup}" -C "${HOME}/.apps/" "${app}2"
  echo "Backup created."
}

uninstall() {
  echo
  echo "Uninstalling second instance of ${app^}.."
  systemctl --user stop "${app}.service"
  systemctl --user disable "${app}.service"
  rm -f "${HOME}/.config/systemd/user/${app}.service"
  systemctl --user daemon-reload
  systemctl --user reset-failed
  rm -rf "${HOME}/.apps/${app}2"
  rm -rf "${HOME}/.config/${app}2"
  rm -f "${HOME}/.apps/nginx/proxy.d/${app}2.conf"
  app-nginx restart
  echo
  echo "Uninstallation Complete."
}

fresh_install() {
  if [ ! -d "${HOME}/.apps/${app}2" ]; then
    echo
    echo "Fresh install of ${app^}2."
    sleep 3
    clear
    port_picker
    required_paths
    get_password
    get_binaries
    create_arr_config
    nginx_conf_install
    systemd_service_install

    systemctl --user --quiet enable --now "${app}.service"
    sleep 10

    create_arr_user

    if systemctl --user is-active --quiet "${app}.service" && systemctl --user is-active --quiet "nginx.service"; then
      echo
      echo "${app^}2 installation is complete."
      echo "Visit the WebUI at the following URL:https://${USER}.${HOSTNAME}.usbx.me/${app}2"
      if [ -n "${backup}" ]; then echo && echo "Backup of old instance has been saved at ${backup}."; fi
      echo
      exit
    else
      echo "Something went wrong. Run the script again." && exit 1
    fi
  fi
}

#Script

backup=''
fresh_install

if [ -d "${HOME}/.apps/${app}2" ]; then
  echo
  echo "Old installation of ${app^}2 detected."
  echo "How do you wish to proceed? In all cases except quit, the old AppData directory will be backed up."

  select status in 'Fresh Install' 'Update & Repair' 'Change Password' 'Uninstall' 'Quit'; do

    case ${status} in
    'Fresh Install')
      systemctl --user stop "${app}.service"
      create_backup
      uninstall
      fresh_install
      break
      ;;
    'Update & Repair')
      systemctl --user stop "${app}.service"
      create_backup
      echo
      echo "Update and Repair ${app^}2"
      sleep 3
      clear
      port_picker
      required_paths
      get_binaries
      nginx_conf_install
      systemd_service_install
      update_arr_config
      systemctl --user restart "${app}.service"
      echo
      echo "${app^}2 has been updated & repaired."
      echo
      exit
      break
      ;;
    'Change Password')
      systemctl --user stop "${app}.service"
      create_backup
      echo
      get_password
      update_arr_user
      systemctl --user restart "${app}.service"
      echo
      echo "${app^}2's password changed successfully."
      echo
      exit
      break
      ;;
    'Uninstall')
      systemctl --user stop "${app}.service"
      create_backup
      uninstall
      echo "Backup of old AppData directory created at ${backup}."
      echo
      exit
      break
      ;;
    'Quit')
      exit 0
      ;;
    *)
      echo "Invalid option $REPLY."
      ;;
    esac
  done
fi