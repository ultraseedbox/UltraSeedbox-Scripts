#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
    exit
fi

clear

cd "${HOME}" || exit 1

#Functions

port_picker() {
  port=''
  while [ -z "${port}" ]; do
    app-ports show
    echo "Pick any application from the list above, that you're not currently using."
    echo "We'll be using this port for autobrr."
    read -rp "$(tput setaf 4)$(tput bold)Application name in full[Example: pyload]: $(tput sgr0)" appname
    proper_app_name=$(app-ports show | grep -i "${appname}" | head -n 1 | cut -c 7-) || proper_app_name=''
    port=$(app-ports show | grep -i "${appname}" | head -n 1 | awk '{print $1}') || port=''
    if [ -z "${port}" ]; then
      echo "$(tput setaf 1)Invalid choice! Please choose an application from the list and avoid typos.$(tput sgr0)"
      echo "$(tput bold)Listing all applications again..$(tput sgr0)"
      sleep 10
      clear
    elif netstat -ntpl | grep "${port}" > /dev/null 2>&1; then
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

ask_yes_or_no() {
    echo "Input 1 or 2: "
    select choice in "Yes" "No"; do
        case ${choice} in
            Yes)
                break
                ;;
            No)
                exit 0
                ;;
            *) 
                exit 0
                ;;
        esac
    done
    echo
}

required_paths() {
    declare -a paths
    paths[1]="${HOME}/.config/autobrr/log"
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

latest_version() {
    echo "Getting latest version of autobrr.."
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/autobrr/autobrr/releases/latest | grep download | grep linux_x86_64 | cut -d\" -f4)
    mkdir -p "${HOME}/.autobrr-tmp"
    wget -qO "${HOME}/.autobrr-tmp/autobrr.tar.gz" "${LATEST_RELEASE}" || {
        echo "Failed to get latest release of autobrr." && exit 1
    }
    rm -rf "${HOME}/bin"/autobrr*
    tar -xf "${HOME}/.autobrr-tmp/autobrr.tar.gz" -C "${HOME}/.autobrr-tmp" && rm "${HOME}/.autobrr-tmp/autobrr.tar.gz"
    cp -r "${HOME}/.autobrr-tmp"/* "${HOME}/bin/"
    rm -rf "${HOME}/.autobrr-tmp"
    echo
}

get_password() {
  while true; do
    read -rsp "The password for autobrr: " password
    echo
    read -rsp "The password for autobrr (again): " password2
    echo
    [ "${password}" = "${password2}" ] && break
    echo "Passwords didn't match, try again."
  done
}

nginx_conf() {
    cat <<EOF | tee "${HOME}/.apps/nginx/proxy.d/autobrr.conf" >/dev/null
location /autobrr/ {
    proxy_pass              http://127.0.0.1:${port};
    proxy_http_version      1.1;
    proxy_set_header        X-Forwarded-Host        \$http_host;

    rewrite ^/autobrr/(.*) /\$1 break;
}
EOF

    app-nginx restart
}

systemd_service() {
    cat <<EOF | tee "${HOME}"/.config/systemd/user/autobrr.service >/dev/null
[Unit]
Description=autobrr
After=syslog.target network-online.target
[Service]
Type=simple
ExecStart=%h/bin/autobrr --config=%h/.config/autobrr/
[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
}

create_user() {

   echo "${password}" | "${HOME}/bin/autobrrctl" --config "${HOME}/.config/autobrr" create-user "${USER}" || {
       echo "Failed to create user." && exit 1
   }
}

update_password() {

    get_password

     echo "${password}" | "${HOME}/bin/autobrrctl" --config "${HOME}/.config/autobrr" change-password "${USER}" || {
        echo
        echo "Failed to change password."
        echo
        exit 1
     }
    echo
    echo "Password changed successfully."
    echo
}

create_config_file() {

    session_secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)

    cat <<EOF | tee "${HOME}"/.config/autobrr/config.toml >/dev/null
host = "127.0.0.1"
port = "${port}"
baseUrl = "/autobrr/"
logPath = "${HOME}/.config/autobrr/log/autobrr.log"
logLevel = "INFO"
sessionSecret = "${session_secret}"
EOF
}

update_config_file(){

    config="${HOME}/.config/autobrr/config.toml"
    if [ ! -f "${config}" ]; then
        echo "autobrr config.toml does not exist."
        echo "Create new one?"
        ask_yes_or_no
        create_config_file
    else
        sed -i "s+host =.*+host = \"127.0.0.1\"+g" "${config}"
        sed -i "s+port =.*+port = \"${port}\"+g" "${config}"
        sed -i "s+baseUrl =.*+baseUrl = \"/autobrr/\"+g" "${config}"
    fi
}

create_backup() {
    backup="${HOME}/.apps/backup/autobrr-$(date +%Y-%m-%d_%H-%M-%S).bak.tar.gz"
    echo
    echo "Creating a backup of the data directory.."
    tar -czf "${backup}" -C "${HOME}/.config/" "autobrr" || {
        backup=''
        return 1
    }
    echo "Backup created."
}

uninstall() {
    echo
    echo "Uninstalling autobrr.."
    if systemctl --user is-enabled --quiet "autobrr.service" || [ -f "${HOME}/.config/systemd/user/autobrr.service" ]; then
        systemctl --user stop autobrr.service
        systemctl --user disable autobrr.service
    fi
    create_backup || {
        echo "Failed to create a backup."
        echo "Do you still wish to continue?"
        ask_yes_or_no
    }
    rm -f "${HOME}/.config/systemd/user/autobrr.service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
    rm -rf "${HOME}/.config/autobrr"
    rm -f "${HOME}/.apps/nginx/proxy.d/autobrr.conf"
    app-nginx restart
    rm -rf "${HOME}/bin"/autobrr*
    echo
    echo "Uninstallation Complete."
}

fresh_install() {
    if [ ! -d "${HOME}/.config/autobrr" ]; then
        echo
        echo "Fresh install of autobrr"
        sleep 3
        clear
        port_picker
        required_paths
        latest_version
        create_config_file
        get_password
        create_user
        systemd_service
        nginx_conf

        systemctl --user --quiet enable --now autobrr.service
        sleep 3

        if systemctl --user is-active --quiet "autobrr.service" && systemctl --user is-active --quiet "nginx.service"; then
            echo
            echo "autobrr installation is complete."
            echo "Access autobrr at the following URL:https://${USER}.${HOSTNAME}.usbx.me/autobrr"
            [ -n "${backup}" ] && echo "Backup of old instance has been saved at ${backup}."
            echo
            exit
        else
            echo "Something went wrong. Run the script again." && exit
        fi
    fi
}

# Script

backup=''
fresh_install

if [ -d "${HOME}/.config/autobrr" ]; then
    echo "Old installation of autobrr detected."
    echo "How do you wish to proceed? In all cases except quit, autobrr will be backed up."

    select status in 'Fresh Install' 'Update & Repair' 'Change Password' 'Uninstall' 'Quit'; do

        case ${status} in
        'Fresh Install')
            uninstall
            fresh_install
            break
            ;;
        'Update & Repair')
            systemctl --user stop autobrr.service || {
                echo "autobrr's systemd service not found. Update & Repair failed." && exit 1
            }
            create_backup || {
                echo "Failed to create a backup. Old install of autobrr does not exist to update." && exit 1 
            }
            echo
            echo "Update & Repair"
            sleep 3
            clear
            port_picker
            required_paths
            latest_version
            update_config_file
            nginx_conf
            systemd_service
            systemctl --user restart autobrr.service
            echo "autobrr has been updated."
            echo
            exit
            break
            ;;
        'Change Password')
            echo
            update_password
            exit
            break
            ;;
        'Uninstall')
            uninstall
            [ -n "${backup}" ] && echo "Backup of old instance created at ${backup}."
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