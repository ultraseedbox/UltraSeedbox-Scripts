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

#Check Python3 version

if ! python3 -V | grep -q -E "3.([7-9]|1[0-9]).*"  &&  ! /usr/bin/python3 -V | grep -q -E "3.([7-9]|1[0-9]).*"id; then
 echo "Bazarr requires python3.7 + to run."
 echo "Please install a python3 version greater than 3.7, then run the script again https://docs.usbx.me/books/pyenv/page/how-to-install-python-using-pyenv"
 exit 1
fi

pythonbinary=$(which python3)

if /usr/bin/python3 -V | grep -q -E "3.([7-9]|1[0-9]).*";then
  pythonbinary="/usr/bin/python3"
fi

#Functions

port_picker() {
  port=''
  while [ -z "${port}" ]; do
    app-ports show
    echo "Pick any application from the list above, that you're not currently using."
    echo "We'll be using this port for the second instance of Bazarr."
    read -rp "$(tput setaf 4)$(tput bold)Application name in full[Example: pyload]: $(tput sgr0)" appname
    proper_app_name=$(app-ports show | grep -i "${appname}" | head -n 1 | cut -c 7-) || proper_app_name=''
    port=$(app-ports show | grep -i "${appname}" | head -n 1 | awk '{print $1}') || port=''
    if [ -z "${port}" ]; then
      echo "$(tput setaf 1)Invalid choice! Please choose an application from the list and avoid typos.$(tput sgr0)"
      echo "$(tput bold)Listing all applications again..$(tput sgr0)"
      sleep 10
      clear
    fi
    if netstat -ntpl | grep "${port}" > /dev/null 2>&1; then
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
  paths[1]="${HOME}/.apps/bazarr2"
  paths[2]="${HOME}/.config/systemd/user"
  paths[3]="${HOME}/.apps/nginx/proxy.d"
  paths[4]="${HOME}/bin"
  paths[5]="${HOME}/.apps/backup"

  for i in {1..5}; do
    if [ ! -d "${paths[${i}]}" ]; then
      mkdir -p "${paths[${i}]}"
    fi
  done
}

get_password() {
  while true; do
    read -rsp "The password for your second instance of Bazarr: " password
    echo
    read -rsp "The password for your second instance of Bazarr (again): " password2
    echo
    [ "${password}" = "${password2}" ] && break
    echo "Passwords didn't match, try again."
  done

  password_hash=$(echo -n "${password}" | md5sum | awk '{print $1}')
}

get_binaries() {
  echo
  echo -n "Pulling new binaries.."
  mkdir -p "${HOME}"/.config/.temp
  [ -d "${HOME}/.apps/bazarr2/data" ] && mv "${HOME}/.apps/bazarr2/data" "${HOME}"/.config/.temp/
  rm -rf "${HOME}/.apps/bazarr2"/*
  wget -qO "${HOME}/.config/.temp/bazarr.zip" --content-disposition "https://github.com/morpheus65535/bazarr/releases/latest/download/bazarr.zip"
  unzip "${HOME}/.config/.temp/bazarr.zip" -d "${HOME}/.apps/bazarr2" >/dev/null 2>&1
  [ -d "${HOME}/.config/.temp/data" ] && mv "${HOME}/.config/.temp/data" "${HOME}/.apps/bazarr2/"
  rm -rf "${HOME}"/.config/.temp
  "${pythonbinary}" -m pip install -q -r "${HOME}/.apps/bazarr2/requirements.txt"
  echo -n "done."
}

nginx_conf_install() {
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

  app-nginx restart
}

systemd_service_install() {
  cat <<EOF | tee "${HOME}"/.config/systemd/user/bazarr.service >/dev/null
[Unit]
Description=Bazarr Daemon
After=network.target
[Service]
WorkingDirectory=%h/.apps/bazarr2
Restart=on-failure
RestartSec=5
Type=simple
ExecStart=${pythonbinary} %h/.apps/bazarr2/bazarr.py
KillSignal=SIGINT
TimeoutStopSec=20
SyslogIdentifier=bazarr
ExecStartPre=/bin/sleep 10
[Install]
WantedBy=default.target
EOF

  systemctl --user daemon-reload
}

update_arr_config() {

  if [ ! -f "${config}" ] || [ -z "$(cat "${config}")" ]; then
    echo
    echo "ERROR: Bazarr2's config.ini does not exist or is empty."
    echo "Repair failed." && exit 1
  fi

  sed -i '/^\[general\]$/,/^\[/ s/ip = .*/ip = 127.0.0.1/g' "${config}"
  sed -i "/^\[general\]$/,/^\[/ s/port = .*/port = ${port}/g" "${config}"
  sed -i '/^\[general\]$/,/^\[/ s/base_url = .*/base_url = \/bazarr2/g' "${config}"
  sed -i '/^\[auth\]$/,/^\[/ s/type = .*/type = form/g' "${config}"

}

create_arr_user() {

  count=1
  while [ ! -f "${config}" ] && [ ${count} -le 6 ]; do
    if [ ${count} -ge 6 ]; then
      echo "Failed to create config.ini, install aborted. Please check port selection, HDD IO and other resource utilization."
      echo "Then run the script again and choose Fresh Install."
      exit 1
    fi
    sleep 5
    count=$(("${count}" + 1))
  done

  systemctl --user stop "bazarr.service"

  sed -i '/^\[general\]$/,/^\[/ s/ip = .*/ip = 127.0.0.1/g' "${config}"
  sed -i "/^\[general\]$/,/^\[/ s/port = .*/port = ${port}/g" "${config}"
  sed -i '/^\[general\]$/,/^\[/ s/base_url = .*/base_url = \/bazarr2/g' "${config}"
  sed -i '/^\[auth\]$/,/^\[/ s/type = .*/type = form/g' "${config}"
  sed -i "/^\[auth\]$/,/^\[/ s/username = .*/username = ${USER}/g" "${config}"
  sed -i "/^\[auth\]$/,/^\[/ s/password = .*/password = ${password_hash}/g" "${config}"

  systemctl --user restart "bazarr.service"

  echo -n "done."

}

update_arr_user() {

  sed -i "/^\[auth\]$/,/^\[/ s/username = .*/username = ${USER}/g" "${config}"
  sed -i "/^\[auth\]$/,/^\[/ s/password = .*/password = ${password_hash}/g" "${config}"

}

create_backup() {
  if [ -d "${HOME}/.apps/bazarr2/data" ]; then
    backup="${HOME}/.apps/backup/bazarr2-$(date +%Y-%m-%d_%H-%M-%S).bak.tar.gz"
    echo
    echo "Creating a backup of the data directory.."
    tar -czf "${backup}" -C "${HOME}/.apps/" "bazarr2/data"
    echo "Backup created."
  else echo "Bazarr2 does not have a data directory. Backup not created."
  fi
}

uninstall() {
  echo
  echo "Uninstalling second instance of Bazarr.."
  if [ -f "${HOME}/.config/systemd/user/bazarr.service" ]; then
    systemctl --user --force stop "bazarr.service"
    systemctl --user --force disable "bazarr.service"
  fi
  rm -f "${HOME}/.config/systemd/user/bazarr.service"
  systemctl --user daemon-reload
  systemctl --user reset-failed
  rm -rf "${HOME}/.apps/bazarr2"
  rm -f "${HOME}/.apps/nginx/proxy.d/bazarr2.conf"
  app-nginx restart
  echo
  echo "Uninstallation Complete."
}

fresh_install() {
  if [ ! -d "${HOME}/.apps/bazarr2" ]; then
    echo
    echo "Fresh install of Bazarr2."
    sleep 3
    clear
    port_picker
    required_paths
    get_password
    get_binaries
    nginx_conf_install
    systemd_service_install

    systemctl --user --quiet enable --now "bazarr.service"
    echo
    echo
    echo -n "Waiting for initial config.."
    sleep 10

    create_arr_user

    if systemctl --user is-active --quiet "bazarr.service" && systemctl --user is-active --quiet "nginx.service"; then
      echo
      echo
      echo "Bazarr2 installation is complete."
      echo "Visit the WebUI at the following URL:https://${USER}.${HOSTNAME}.usbx.me/bazarr2"
      if [ -n "${backup}" ]; then echo && echo "Backup of old instance has been saved at ${backup}"; fi
      echo
      exit
    else
      echo "Something went wrong. Run the script again." && exit 1
    fi
  fi
}

#Script

backup=''
config="${HOME}/.apps/bazarr2/data/config/config.ini"
fresh_install

if [ -d "${HOME}/.apps/bazarr2" ]; then
  echo "Old installation of Bazarr2 detected."
  echo "How do you wish to proceed? In all cases except quit, the old data directory will be backed up."

  select status in 'Fresh Install' 'Update & Repair' 'Change Password' 'Uninstall' 'Quit'; do

    case ${status} in
    'Fresh Install')
      [ -f "${HOME}/.config/systemd/user/bazarr.service" ] && systemctl --user --force stop "bazarr.service"
      create_backup
      uninstall
      fresh_install
      break
      ;;
    'Update & Repair')
      systemctl --user stop "bazarr.service"
      create_backup
      echo
      echo "Update and Repair Bazarr2"
      sleep 3
      clear
      port_picker
      required_paths
      get_binaries
      nginx_conf_install
      systemd_service_install
      update_arr_config
      systemctl --user restart "bazarr.service"
      echo
      echo "Bazarr2 has been updated & repaired."
      echo
      exit
      break
      ;;
    'Change Password')
      systemctl --user stop "bazarr.service"
      create_backup
      echo
      get_password
      update_arr_user
      systemctl --user restart "bazarr.service"
      echo
      echo "Bazarr2's password changed successfully."
      echo
      exit
      break
      ;;
    'Uninstall')
      [ -f "${HOME}/.config/systemd/user/bazarr.service" ] && systemctl --user stop "bazarr.service"
      create_backup
      uninstall
      test -n "${backup}" && echo "Backup of old AppData directory created at ${backup}."
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