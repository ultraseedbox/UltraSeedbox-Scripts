#!/bin/bash

if test -f "$HOME/transfer/.config/systemd/user/rclone-vfs.service"; then
   cp $HOME/transfer/.config/systemd/user/rclone-vfs.service $HOME/.config/systemd/user/
   sed -i 's/$HOME/%h/g' $HOME/.config/systemd/user/rclone-vfs.service
   systemctl --user daemon-reload
   systemctl --user restart rclone-vfs.service
   echo "rclone-vfs service edited and restarted"
else echo "rclone-vfs.service not found in transfer folder"
fi

if test -f "$HOME/transfer/.config/systemd/user/mergerfs.service"; then
   cp $HOME/transfer/.config/systemd/user/mergerfs.service $HOME/.config/systemd/user/
   sed -i 's/$HOME/%h/g' $HOME/.config/systemd/user/mergerfs.service
   systemctl --user daemon-reload
   systemctl --user restart mergerfs.service
   echo "mergerfs service edited and restarted"
else echo "mergerfs.service not found in transfer folder"
fi