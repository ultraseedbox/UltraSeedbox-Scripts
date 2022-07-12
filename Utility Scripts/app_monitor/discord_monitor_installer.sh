#!/bin/bash

if [ ! -d "$HOME/scripts" ]; then
  mkdir -p "$HOME/scripts/app_monitor"
fi



wget -P $HOME/scripts/app_monitor/ https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/Utility%20Scripts/app_monitor/app_discord_notification.py

clear

croncmd="/usr/bin/python3 $HOME/scripts/app_monitor/app_discord_notification.py > /dev/null 2>&1"
cronjob="*/5 * * * * $croncmd"
(
    crontab -l 2>/dev/null | grep -v -F "$croncmd" || :
    echo "$cronjob"
) | crontab -


/usr/bin/python3 $HOME/scripts/app_monitor/app_discord_notification.py

