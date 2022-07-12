#!/bin/bash

printf "\033[0;31mDisclaimer: This Script is unofficial and Ultra.cc staff will not support any issues with it will monitor your applications and restart them if application are not running it\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi

printf "Please choose option from below if you want notification on discord or info as a log file on your service\n"
printf "1. Store Applications status on your service at {~/script/app_monitor}\n"
printf "2. To get application status on your Discord(You need Discord Webhook for it)\n"

read -rp "Please select option 1 or 2: " choice

if [ "$choice" = "1" ]; then
  bash <(wget -qO- https://raw.githubusercontent.com/yashgupta-112/app_monitor/master/Monitor_installer.sh)
fi

if [ "$choice" = "2" ]; then
  bash <(wget -qO- https://raw.githubusercontent.com/yashgupta-112/app_monitor/master/Discord_monitor_installer.sh)
fi

if [ ! "$choice" = "1" ] && [ ! "$choice" = "2" ]; then
  echo "Wrong choice"
fi