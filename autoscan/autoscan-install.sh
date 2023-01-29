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
    echo "Listing free ports.."
    app-ports free
    echo "Pick any application from the list above, that you do not plan to use in the future."
    echo "We'll be using this port for autoscan."
    read -rp "$(tput setaf 4)$(tput bold)Application name in full[Example: pyload]: $(tput sgr0)" appname
    proper_app_name=$(app-ports show | grep -i "${appname}" | head -n 1 | cut -c 7-) || proper_app_name=''
    port=$(app-ports show | grep -i "${appname}" | head -n 1 | awk '{print $1}') || port=''
    if [ -z "${port}" ]; then
      echo "$(tput setaf 1)Invalid choice! Please choose an application from the list and avoid typos.$(tput sgr0)"
      echo "$(tput bold)Listing all applications again..$(tput sgr0)"
      sleep 6
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

media_server(){

    plexport=$(app-ports show | grep "Plex Media Server" | head -n 1 | awk '{print $1}') || plexport=''
    embyport=$(app-ports show | grep "Emby" | head -n 1 | awk '{print $1}') || embyport=''
    jellyport=$(app-ports show | grep "Jellyfin" | head -n 1 | awk '{print $1}') || jellyport=''

    echo
    echo "Which media server are you planning to use autoscan with?"

    select server in "Plex Media Server" "Emby" "Jellyfin"; do

        case ${server} in
            "Plex Media Server")
                target='plex'
                target2='emby'
                target3='jellyfin'
                serverport="${plexport}"
                url="http://172.17.0.1:${serverport}"
                url2="http://172.17.0.1:${embyport}"
                url3="http://172.17.0.1:${jellyport}/jellyfin"
                auth="${url}/?X-Plex-Token"
                break
                ;;
            "Emby")
                target='emby'
                target2='plex'
                target3='jellyfin'
                serverport="${embyport}"
                url="http://172.17.0.1:${serverport}"
                url2="http://172.17.0.1:${plexport}"
                url3="http://172.17.0.1:${jellyport}/jellyfin"
                auth="${url}/System/Info?Api_key"
                break
                ;;
            "Jellyfin")
                target='jellyfin'
                target2='plex'
                target3='emby'
                serverport="${jellyport}"
                url="http://172.17.0.1:${serverport}/jellyfin"
                url2="http://172.17.0.1:${plexport}"
                url3="http://172.17.0.1:${embyport}"
                auth="${url}/System/Info?Api_key"
                break
                ;;
            *)
                echo "ERROR: Invalid option $REPLY. Input [ 1 - 3 ]."
                ;;
        esac
    done

    [ "${serverport}" = '' ] && {
        echo "ERROR: ${server} port not found."
        exit 1
    }

    while true; do
        echo
        read -rp "Enter the ${server} authentication token: " servertoken
        echo
        curl -fs "${auth}=${servertoken}" > /dev/null && break
        echo "ERROR: ${server} authentication failed, try again."
    done
}

latest_version() {
    mkdir -p "${HOME}/.apps/autoscan"
    echo "Getting latest version of autoscan.."
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/Cloudbox/autoscan/releases/latest | grep download | grep linux_amd64 | cut -d\" -f4)
    mkdir -p "${HOME}/.autoscan-tmp"
    wget -qO "${HOME}/.autoscan-tmp/autoscan" "${LATEST_RELEASE}" || {
        echo "Failed to get latest release of autoscan." 
        rm -rf "${HOME}/.autoscan-tmp"  
        exit 1
    }
    rm -rf "${HOME}/bin/autoscan"
    cp "${HOME}/.autoscan-tmp/autoscan" "${HOME}/bin/" && chmod +x "${HOME}/bin/autoscan"
    rm -rf "${HOME}/.autoscan-tmp"
}

get_password() {
  while true; do
    read -rsp "The password for autoscan: " password
    echo
    read -rsp "The password for autoscan (again): " password2
    echo
    [ "${password}" = "${password2}" ] && break
    echo "ERROR: Passwords didn't match, try again."
  done
}

create_config_file() {

    cat <<EOF | tee "${HOME}"/.apps/autoscan/config.yml >/dev/null
################################################################
# This is just a basic config file. For more options, see:     #
# https://github.com/Cloudbox/autoscan/blob/master/README.md   #
################################################################

minimum-age: 2m30s
scan-delay: 15s
scan-stats: 15m

authentication:
  username: ${USER}
  password: ${password}

port: ${port}

triggers:
  manual:
    priority: 0

  sonarr:
    - name: sonarr
      priority: 1

  radarr:
    - name: radarr
      priority: 1

targets:
  ${target}:
    - url: ${url}
      token: ${servertoken}

#  ${target2}:
#    - url: ${url2}
#      token: <token>

#  ${target3}:
#    - url: ${url3}
#      token: <token>

#anchors:
#  - ${HOME}/MergerFS/.anchor
EOF
}

systemd_service() {
    cat <<EOF | tee "${HOME}"/.config/systemd/user/autoscan.service >/dev/null
[Unit]
Description=autoscan
After=network-online.target
[Service]
Type=simple
ExecStart=%h/bin/autoscan --config="%h/.apps/autoscan/config.yml" \
    --database="%h/.apps/autoscan/autoscan.db" \
    --log="%h/.apps/autoscan/activity.log"
[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
}

uninstall() {
    echo
    echo "Uninstalling autoscan.."
    if systemctl --user is-enabled --quiet "autoscan.service" || [ -f "${HOME}/.config/systemd/user/autoscan.service" ]; then
        systemctl --user stop autoscan.service
        systemctl --user --quiet disable autoscan.service
    fi
    rm -f "${HOME}/.config/systemd/user/autoscan.service"
    systemctl --user daemon-reload
    systemctl --user reset-failed
    rm -rf "${HOME}/.apps/autoscan"
    rm -f "${HOME}/bin/autoscan"
    echo
    echo "Uninstallation Complete."
}

fresh_install() {
    if [ ! -d "${HOME}/.apps/autoscan" ]; then
        echo
        echo "Fresh install of autoscan"
        sleep 3
        clear
        port_picker
        get_password
        media_server
        latest_version
        create_config_file
        systemd_service

        systemctl --user --quiet enable --now autoscan.service
        sleep 3

        if systemctl --user is-active --quiet "autoscan.service"; then
            echo
            echo "autoscan installation is complete."
            echo
            echo "Webhook URLs"
            echo "Sonarr: http://172.17.0.1:${port}/triggers/sonarr"
            echo "Radarr: http://172.17.0.1:${port}/triggers/radarr"
            echo
            exit 0
        else
            echo "ERROR: Something went wrong. Run the script again." && exit 1
        fi
    fi
}

#Script

fresh_install

if [ -d "${HOME}/.apps/autoscan" ]; then
    echo "Old installation of autoscan detected."
    echo "How do you wish to proceed?"

    select status in 'Fresh Install' 'Update to latest release' 'Uninstall' 'Quit'; do

        case ${status} in
        'Fresh Install')
            uninstall
            fresh_install
            break
            ;;
        'Update to latest release')
            systemctl --user stop autoscan.service || {
                echo "ERROR: Unable to stop autoscan. Update failed." && exit 1
            }
            echo
            echo "Update to latest release"
            sleep 3
            clear
            latest_version
            echo
            systemctl --user restart autoscan.service
            echo "autoscan has been updated."
            echo
            exit 0
            ;;
        'Uninstall')
            uninstall
            exit 0
            ;;
        'Quit')
            exit 0
            ;;
        *)
            echo "Invalid option $REPLY. Input [ 1 - 4 ]"
            ;;
        esac
    done
fi