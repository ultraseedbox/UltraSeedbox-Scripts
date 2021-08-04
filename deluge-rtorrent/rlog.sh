#!/bin/bash

app-rtorrent stop
mkdir -p $HOME/.config/rtorrent/logs
cp $HOME/.config/rtorrent/rtorrent.rc $HOME/.config/rtorrent/rtorrent.rc.bak
echo "#logs
log.open_file = "rtorrent", ~/.config/rtorrent/logs/rtorrent.log
log.open_file = "tracker", ~/.config/rtorrent/logs/tracker.log
log.open_file = "storage", ~/.config/rtorrent/logs/storage.log
    
log.add_output = "info", "rtorrent"
log.add_output = "critical", "rtorrent"
log.add_output = "error", "rtorrent"
log.add_output = "warn", "rtorrent"
log.add_output = "notice", "rtorrent"
log.add_output = "debug", "rtorrent"
    
log.add_output = "dht_debug", "tracker"
log.add_output = "tracker_debug", "tracker"
  
log.add_output = "storage_debug", "storage"" >> $HOME/.config/rtorrent/rtorrent.rc
app-rtorrent restart
sleep 2
tail -f $HOME/.config/rtorrent/logs/rtorrent.log

