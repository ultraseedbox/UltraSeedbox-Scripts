#!/bin/bash
set -e
#Get NextCloud DB passwords
read -sp 'NextCloud DB Password Old Slot: ' nextcloud_old
echo
read -sp 'NextCloud DB Password New Slot: ' nextcloud_new
echo

#Get Oldslot details
read -p 'Old slot username: ' uservar
read -p 'Old slot servername: ' server
servername=$server.usbx.me

#Dump Old Nextcloud DB
echo "Dumping NextCloud DB on Old slot.."
PASS=$nextcloud_old
ssh -T $uservar@$servername PASS=$PASS 'bash -s' <<'ENDSSH'
app-nextcloud stop
app-mariadb restart && sleep 10
port=$(app-ports show | grep MySQL | awk {'print $1'})
nextcloud_old=$PASS
mysqldump -P $port -h 127.0.0.1 -u nextcloud -p$nextcloud_old nextcloud > nextcloudbak.sql
mv nextcloudbak.sql ~/.apps/nextcloud/
ENDSSH
echo "Done!"

#Get files from Old slot
echo "Transferring files from Old slot to New slot.."
rsync -aHAXxv $uservar@$servername:.apps/nextcloud/ .apps/nextcloud.bak
echo "Done!"

#Restore NextCloud on New slot
echo "Restoring NextCloud.."
port=$(app-ports show | grep MySQL | awk {'print $1'})
app-nextcloud stop
rm -rf ~/.apps/nextcloud && mv ~/.apps/nextcloud.bak ~/.apps/nextcloud && cd ~/.apps/nextcloud
mysql -P $port -h 127.0.0.1 -u nextcloud -p$nextcloud_new -e "DROP DATABASE nextcloud"
mysql -P $port -h 127.0.0.1 -u nextcloud -p$nextcloud_new -e "CREATE DATABASE nextcloud"
mysql -P $port -h 127.0.0.1 -u nextcloud -p$nextcloud_new nextcloud < nextcloudbak.sql
app-nextcloud upgrade -p $nextcloud_new
echo "Done!"

#Perform Cleanup
echo "Performing Cleanup.."
rm ~/.apps/nextcloud/nextcloudbak.sql
ssh -T $uservar@$servername 'bash -s' <<'ENDSSH'
rm ~/.apps/nextcloud/nextcloudbak.sql
app-mariadb stop
ENDSSH
echo "Done!"
