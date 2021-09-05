#!/bin/bash

if [ -d "$HOME/.config/rtorrent/logs" ];
then
    echo "rTorrent logging already enabled. Exiting..."
    exit
fi

app-rtorrent stop
mkdir -p $HOME/.config/rtorrent/logs
cp $HOME/.config/rtorrent/rtorrent.rc $HOME/.config/rtorrent/rtorrent.rc.bak
echo "#logs
log.open_file = "rtorrent", ~/.config/rtorrent/logs/rtorrent.log
log.open_file = "tracker", ~/.config/rtorrent/logs/tracker.log
log.open_file = "storage", ~/.config/rtorrent/logs/storage.log
log.open_file = "network", ~/.config/rtorrent/logs/network.log   

log.add_output = "info", "rtorrent"
log.add_output = "critical", "rtorrent"
log.add_output = "error", "rtorrent"
log.add_output = "warn", "rtorrent"
log.add_output = "notice", "rtorrent"
log.add_output = "debug", "rtorrent"
    
log.add_output = "dht_debug", "tracker"
log.add_output = "tracker_debug", "tracker"
  
log.add_output = "storage_debug", "storage"

log.add_output = "connection_debug", "network"
log.add_output = "socket_error", "network"
log.add_output = "socket_warn", "network"
log.add_output = "socket_notice", "network"
log.add_output = "socket_info", "network"
log.add_output = "socket_debug", "network"" >> $HOME/.config/rtorrent/rtorrent.rc
app-rtorrent restart
sleep 2
echo "rTorrent logging enabled. All log files located in ~/.config/rtorrent/logs".
