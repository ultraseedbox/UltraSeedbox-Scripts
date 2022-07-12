#!/bin/bash

if [ ! -d "$HOME/scripts" ]; then
  mkdir -p "$HOME/scripts/app_monitor"
fi

script_path="${HOME}/scripts/app_monitor/app_status_check.py"

wget -P "${HOME}"/scripts/app_monitor/ https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/Utility%20Scripts/app_monitor/app_status_check.py

clear

croncmd="/usr/bin/python3 ${script_path} > /dev/null 2>&1"
cronjob="*/5 * * * * $croncmd"
(
    crontab -l 2>/dev/null | grep -v -F "$croncmd" || :
    echo "$cronjob"
) | crontab -

croncmd="rm -rf $HOME/scripts/app_monitor/docker_apps.txt  $HOME/script/app_monitor/torrentapps.txt"
cronjob="0 0 1 * * $croncmd"
(
    crontab -l 2>/dev/null | grep -v -F "$croncmd" || :
    echo "$cronjob"
) | crontab -


/usr/bin/python3 "${script_path}"