#!/bin/bash

echo "Stopping ProFTPD..."
systemctl --user stop proftpd

echo "Removing Directory..."
rm -rf $HOME/.config/proftpd

echo "Removing Service..."
rm $HOME/.config/systemd/user/proftpd.service
systemctl --user daemon-reload

echo "Cleaning up..."

rm $HOME/proftpd-users.sh

echo "Done!"