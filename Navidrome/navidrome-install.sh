#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
    exit
fi

#Functions

port_picker() {
    port=''
    while [ -z "${port}" ]; do
        app-ports show
        echo "Pick any application from the list above, that you're not currently using."
        echo "We'll be using this port for Navidrome."
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
}

required_paths() {
    declare -a paths
    paths[1]="${HOME}/.apps/navidrome"
    paths[2]="${HOME}/.config/systemd/user"
    paths[3]="${HOME}/.apps/nginx/proxy.d"
    paths[4]="${HOME}/bin"
    paths[5]="${HOME}/.apps/backup"
    paths[6]="${HOME}/media/Music"

    for i in {1..6}; do
        if [ ! -d "${paths[${i}]}" ]; then
            mkdir -p "${paths[${i}]}"
        fi
    done
}

latest_version() {
    echo "Getting latest binary of Navidrome.."
    LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/navidrome/navidrome/releases/latest)
    #shellcheck disable=SC2001
    LATEST_VERSION=$(echo "$LATEST_RELEASE" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
    mkdir -p "${HOME}/.navidrome-tmp"
    wget -qO "${HOME}/.navidrome-tmp/navidrome.tar.gz" "https://github.com/navidrome/navidrome/releases/download/${LATEST_VERSION}/navidrome_${LATEST_VERSION:1}_Linux_x86_64.tar.gz"
    rm -f "${HOME}/bin/navidrome"
    tar -xf "${HOME}/.navidrome-tmp/navidrome.tar.gz" -C "${HOME}/.navidrome-tmp"
    cp "${HOME}/.navidrome-tmp/navidrome" "${HOME}/bin/"
    rm -rf "${HOME}/.navidrome-tmp"
    echo
    "${HOME}/bin/navidrome" "-v"
}

nginx_conf() {
    cat <<EOF | tee "${HOME}/.apps/nginx/proxy.d/navidrome.conf" >/dev/null
location /navidrome {
    proxy_pass http://127.0.0.1:${port};
    proxy_set_header Host \$host;
}
EOF

    app-nginx restart
}

systemd_service() {
    cat <<EOF | tee "${HOME}"/.config/systemd/user/navidrome.service >/dev/null
[Unit]
Description=Navidrome Music Server and Streamer compatible with Subsonic/Airsonic
After=network.target
AssertPathExists=%h/.apps/navidrome

[Install]
WantedBy=default.target

[Service]
Type=simple
ExecStart=%h/bin/navidrome --configfile "%h/.apps/navidrome/navidrome.toml"
WorkingDirectory=%h/.apps/navidrome
TimeoutStopSec=20
KillMode=process
Restart=on-failure

# See https://www.freedesktop.org/software/systemd/man/systemd.exec.html
PrivateTmp=yes
ReadWritePaths=%h/.apps/navidrome

# You can uncomment the following line if you're not using the jukebox This
# will prevent navidrome from accessing any real (physical) devices
#PrivateDevices=yes

# You can change the following line to 'strict' instead of 'full' if you don't
# want navidrome to be able to write anything on your filesystem outside of
# /var/lib/navidrome.
ProtectSystem=full

# You can uncomment the following line if you don't have any media in /home/*.
# This will prevent navidrome from ever reading/writing anything there.
#ProtectHome=true

# You can customize some Navidrome config options by setting environment variables here. Ex:
Environment=ND_BASEURL="/navidrome"
Environment=ND_PORT="${port}"
Environment=ND_ADDRESS="127.0.0.1"
Environment=ND_DATAFOLDER="${HOME}/.apps/navidrome"
EOF

    systemctl --user daemon-reload
}

config_file() {
    cat <<EOF | tee "${HOME}"/.apps/navidrome/navidrome.toml >/dev/null
MusicFolder = "${HOME}/media/Music"
ScanSchedule = "@every 24h"
LogLevel = "info"
EOF
}

create_backup() {
    backup="${HOME}/.apps/backup/navidrome-$(date +%Y-%m-%d_%H-%M-%S).bak.tar.gz"
    echo
    echo "Creating a backup of the data directory.."
    tar -czf "${backup}" -C "${HOME}/.apps/" "navidrome"
    echo "Backup created."
}

uninstall() {
    echo
    echo "Uninstalling Navidrome.."
    systemctl --user stop navidrome.service
    systemctl --user disable navidrome.service
    rm -f "${HOME}/.config/systemd/user/navidrome.service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
    rm -rf "${HOME}/.apps/navidrome"
    rm -rf "${HOME}/.apps/nginx/proxy.d/navidrome.conf"
    app-nginx restart
    rm -f "${HOME}/bin/navidrome"
    echo
    echo "Uninstallation Complete."
}

fresh_install() {
    if [ ! -d "${HOME}/.apps/navidrome" ]; then
        echo
        echo "Fresh install of Navidrome"
        sleep 3
        clear
        port_picker
        required_paths
        latest_version
        config_file
        nginx_conf
        systemd_service

        systemctl --user --quiet enable --now navidrome.service
        sleep 3

        if systemctl --user is-active --quiet "navidrome.service" && systemctl --user is-active --quiet "nginx.service"; then
            echo
            echo "Navidrome installation is complete."
            echo "Create the Navidrome Admin account at the following URL:https://${USER}.${HOSTNAME}.usbx.me/navidrome"
            echo
            echo "The default Music folder is set to the following path: '${HOME}/media/Music'."
            echo "This can be changed by editing '${HOME}/.apps/navidrome/navidrome.toml'."
            if [ -n "${backup}" ]; then echo && echo "Backup of old instance has been saved at ${backup}."; fi
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

if [ -d "${HOME}/.apps/navidrome" ]; then
    echo
    echo "Old installation of Navidrome detected."
    echo "How do you wish to proceed? In all the first three cases, the old data directory will be backed up."

    select status in 'Fresh Install' 'Update & Repair' 'Uninstall' 'Quit'; do

        case ${status} in
        'Fresh Install')
            systemctl --user stop navidrome.service
            create_backup
            uninstall
            fresh_install
            break
            ;;
        'Update & Repair')
            systemctl --user stop navidrome.service
            create_backup
            echo
            echo "Update and Repair Navidrome"
            sleep 3
            clear
            port_picker
            required_paths
            latest_version
            nginx_conf
            systemd_service
            systemctl --user restart navidrome.service
            echo
            echo "Navidrome has been updated."
            echo
            exit
            break
            ;;
        'Uninstall')
            systemctl --user stop navidrome.service
            create_backup
            uninstall
            echo "Backup of old instance created at ${backup}."
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