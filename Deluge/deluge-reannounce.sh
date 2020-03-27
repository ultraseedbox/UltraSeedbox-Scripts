#!/bin/bash

# This script required the update-tracker.py from https://raw.githubusercontent.com/s0undt3ch/Deluge/master/deluge/ui/console/commands/update-tracker.py

# Change the below output location to any folder owned by your user for which you have write permissions
OUTPUT="/homeXX/user/scripts"

torrentid=$1
torrentname=$2
torrentpath=$3

# Update the ip, port, username and pass below according to your configuration
ip=xyz.xyz.xyz.xyz
port=zzzzz
username=yyyyyyy
password=xxxxxxx

x=1
while [ $x -le 1000 ]
do
  sleep 3
  echo "Running $x times" >> "${OUTPUT}/reannounce.log"
  echo "TorrentID: $torrentid" >> "${OUTPUT}/reannounce.log"
  info=$(deluge-console "connect '$ip':'$port' '$username' '$password'; info" $1)
  line=$(echo "$info" | grep "Tracker status")
  # echo $line >> "${OUTPUT}/reannounce.log"
  case "$line" in
    # if tracker is error status reannounce
    *Unregistered*|*unregistered*|*Sent*|*End*of*file*|*Bad*Gateway*|*Error*)
        # deluge-console "connect '$ip':'$port' '$username' '$password'; pause '$torrentid'; resume '$torrentid'" >> "${OUTPUT}/deluge.output" 2>&1
        deluge-console "connect '$ip':'$port' '$username' '$password'; update-tracker '$torrentid'" >> "${OUTPUT}/deluge.output" 2>&1
        ;;
    # if tracker is working fine output to log and exit
    *)
        echo "Found working torrent: $torrentname $torrentpath $torrentid" >> "${OUTPUT}/reannounce.log" 2>&1
        exit 1
        ;;
  esac
  x=$(( $x + 1 ))
done
