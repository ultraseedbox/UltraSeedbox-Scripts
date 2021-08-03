#!/bin/bash

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

if test -f "$HOME/.migration/.config/systemd/user/rclone-vfs.service"; then
   cp $HOME/.migration/.config/systemd/user/rclone-vfs.service $HOME/.config/systemd/user/
   sed -i -E "s+/home[0-9]{0,2}/\w*+%h+g" $HOME/.config/systemd/user/rclone-vfs.service
   systemctl --user daemon-reload
   systemctl --user enable rclone-vfs.service
   systemctl --user restart rclone-vfs.service
   echo -e "${GREEN}rclone-vfs service edited and restarted${NOCOLOR}"
else echo -e "${RED}rclone-vfs.service not found in .migration folder${NOCOLOR}"
fi

if test -f "$HOME/.migration/.config/systemd/user/mergerfs.service"; then
   cp $HOME/.migration/.config/systemd/user/mergerfs.service $HOME/.config/systemd/user/
   sed -i -E "s+/home[0-9]{0,2}/\w*+%h+g" $HOME/.config/systemd/user/mergerfs.service
   systemctl --user daemon-reload
   systemctl --user enable mergerfs.service
   systemctl --user restart mergerfs.service
   echo -e "${GREEN}mergerfs service edited and restarted${NOCOLOR}"
else echo -e "${RED}mergerfs.service not found in .migration folder${NOCOLOR}"
fi

if test -f "$HOME/.migration/.config/systemd/user/rclone-uploader.service" && test -f "$HOME/.migration/.config/systemd/user/rclone-uploader.timer"; then
   cp $HOME/.migration/.config/systemd/user/rclone-uploader.service $HOME/.config/systemd/user/ && cp $HOME/.migration/.config/systemd/user/rclone-uploader.timer $HOME/.config/systemd/user/
   sed -i -E "s+/home[0-9]{0,2}/\w*+%h+g" $HOME/.config/systemd/user/rclone-uploader.service
   systemctl --user daemon-reload
   systemctl --user enable --now rclone-uploader.service && systemctl --user enable --now rclone-uploader.timer
   echo -e "${GREEN}rclone-uploader service & timer edited and enabled${NOCOLOR}"
else echo -e "${RED}rclone-uploader or rclone-uploader.timer not found in .migrations folder${NOCOLOR}"
fi
