#!/bin/bash

set -euo pipefail

if [ ! -d "${HOME}/scripts/app_monitor" ]; then
  mkdir -p "${HOME}/scripts/app_monitor"
fi

printf "\033[0;31mDisclaimer: This script is unofficial and Ultra.cc staff will not support any issues with it. The script will monitor your applications and restart them if they are not running.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi

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

install() {
  wget -qO "${HOME}/scripts/app_monitor/app_monitor.py" "https://scripts.usbx.me/util/app_monitor/app_monitor${status}.py"

  clear

  croncmd="/usr/bin/python3 $HOME/scripts/app_monitor/app_monitor.py > /dev/null 2>&1"
  cronjob="*/5 * * * * $croncmd"
  (
    crontab -l 2>/dev/null | grep -v -F "$croncmd" || :
    echo "$cronjob"
  ) | crontab -

  /usr/bin/python3 "${HOME}/scripts/app_monitor/app_monitor.py"
}

uninstall() {
  croncmd="/usr/bin/python3 $HOME/scripts/app_monitor/app_monitor.py > /dev/null 2>&1"

  ( crontab -l | grep -v -F "$croncmd" || : ) | crontab -

  rm -rf "${HOME}/scripts/app_monitor"

  echo "Uninstall complete."
}

if [ ! -f "${HOME}/scripts/app_monitor/app_monitor.py" ];then

  echo "Please choose option from below if you want notification on discord or info as a log file on your service."

  select status in 'Store logs at ~/scripts/app_monitor' 'Get Discord Notifications' 'Quit'; do
    case ${status} in
    'Store logs at ~/scripts/app_monitor')
      status=""
      install
      break
      ;;
    'Get Discord Notifications')
      status="_discord"
      install
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
else
  echo "App Monitor is already installed. Do you wish to uninstall it?"
  yes_no
  uninstall
fi

exit 0