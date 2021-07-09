#!/bin/bash
if test -f "$HOME/transfer/.config/systemd/user/rclone-vfs.service"; then
   cp $HOME/transfer/.config/systemd/user/rclone-vfs.service $HOME/.config/systemd/user/
   sed -i -E "s+/home[0-9]{0,2}/\w*+%h+g" $HOME/.config/systemd/user/rclone-vfs.service
   systemctl --user daemon-reload
   systemctl --user enable rclone-vfs.service
   systemctl --user restart rclone-vfs.service
   echo "${green}rclone-vfs service edited and restarted"
else echo "${red}rclone-vfs.service not found in transfer folder"
fi

if test -f "$HOME/transfer/.config/systemd/user/mergerfs.service"; then
   cp $HOME/transfer/.config/systemd/user/mergerfs.service $HOME/.config/systemd/user/
   sed -i -E "s+/home[0-9]{0,2}/\w*+%h+g" $HOME/.config/systemd/user/mergerfs.service
   systemctl --user daemon-reload
   systemctl --user enable mergerfs.service
   systemctl --user restart mergerfs.service
   echo "${green}mergerfs service edited and restarted"
else echo "${red}mergerfs.service not found in transfer folder"
fi

if test -f "$HOME/transfer/.config/systemd/user/rclone-uploader.service" && test -f "$HOME/transfer/.config/systemd/user/rclone-uploader.timer"; then
   cp $HOME/transfer/.config/systemd/user/rclone-uploader.service $HOME/.config/systemd/user/ && cp $HOME/transfer/.config/systemd/user/rclone-uploader.timer $HOME/.config/systemd/user/
   sed -i -E "s+/home[0-9]{0,2}/\w*+%h+g" $HOME/.config/systemd/user/rclone-uploader.service
   systemctl --user daemon-reload
   systemctl --user enable --now rclone-uploader.service && systemctl --user enable --now rclone-uploader.timer
   echo "${green}rclone-uploader service & timer edited and enabled"
else echo "${red}rclone-uploader or rclone-uploader.time not found in transfer folder"
fi
