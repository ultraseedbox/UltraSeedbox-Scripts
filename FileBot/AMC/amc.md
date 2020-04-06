## FileBot AMC

### Prerequisites

Before adding the scripts, make sure to do the following:

1. SSH in and create a folder to save your AMC scripts by doing `mkdir -p ~/scripts/amc`
2. Then choose the following script based on the torrent client you used.

### AMC Scripts
#### rtorrent

1. `wget -P ~/scripts/amc https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/filebot-amc/FileBot/AMC/rtorrent-amc.sh && chmod +rx ~/scripts/amc/rtorrent-amc.sh`
2. `sed -i '/method.set_key = event.download.finished,filebot/d' ~/.config/rtorrent/rtorrent.rc`
3. `echo 'method.set_key = event.download.finished,filebot,"execute.nothrow=~/scripts/amc/rtorrent-amc.sh,$d.base_path=,$d.name=,$d.custom1="' >> ~/.config/rtorrent/rtorrent.rc` where `/homexx/username` is your seedbox's full path

#### Deluge

1. `wget -P ~/scripts/amc https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/filebot-amc/FileBot/AMC/deluge-amc.sh && chmod +rx ~/scripts/amc/deluge-amc.sh`
2. `~/scripts/amc/deluge-amc.sh` and copy the output
3. In Deluge, Go to Preferences -> Execute. Set the following:

```
Event: Torrent Complete
Command: the output of ~/scripts/amc/deluge-amc.sh (EG /homexx/username/amc/scripts/deluge-amc.sh)
```
4. Press OK and `app-deluge restart`