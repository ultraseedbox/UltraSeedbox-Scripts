#!/bin/bash

set -euo pipefail

echo "This script will monitor your traffic and stop torrent clients if traffic limit set by you is reached it will help you to save your traffic."
printf "\033[0;31mDisclaimer: The script is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
printf "\033[0;31mDO NOT completely rely on this script to manage your upload traffic.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
    exit
fi

cd "${HOME}" || exit 1

clear

#Yes or no function

yes_no() {
    select choice in "Yes" "No"; do
        case ${choice} in
        Yes)
            break
            ;;
        No)
            exit 0
            ;;
        *)
            echo "Invalid option $REPLY."
            ;;
        esac
    done
    echo
}

# Installer function

installer() {

    if [ ! -d "$HOME/scripts/traffic_monitor" ]; then
        mkdir -p "$HOME/scripts/traffic_monitor"
    fi

    wget -q -P "${HOME}/scripts/traffic_monitor/" https://scripts.usbx.me/util/Traffic_monitor/Traffic_monitor.py

    clear

    croncmd="/usr/bin/python3 $HOME/scripts/traffic_monitor/Traffic_monitor.py > /dev/null 2>&1"
    cronjob="*/$1 * * * * $croncmd"
    (
        crontab -l 2>/dev/null | grep -v -F "$croncmd" || :
        echo "$cronjob"
    ) | crontab -

    /usr/bin/python3 "${HOME}/scripts/traffic_monitor/Traffic_monitor.py" && printf "\nInstallation Complete!\n" || echo "Installation failed."
}

#uninstall function

uninstall() {
    rm -rf "${HOME}/scripts/traffic_monitor"
    crontab -l | grep -v traffic_monitor | crontab -
    echo "The script has been uninstalled."
    sleep 2
    clear
}

if [ ! -d "$HOME/scripts/traffic_monitor" ]; then
    echo "Please enter the time interval in which you want the script to check your traffic (Minutes)."
    echo "For example, enter 5 for the script to run a check every 5 minutes."
    read -rp "Time Interval [in minutes]: " time
    installer "${time}"

else
    echo "The script is already installed. Do you wish to uninstall it?"
    yes_no
    uninstall
fi

exit 0