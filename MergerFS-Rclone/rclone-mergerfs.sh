#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi

declare -a paths
paths[1]="${HOME}/Stuff/Mount"
paths[2]="${HOME}/Stuff/Local/Downloads/torrents"
paths[3]="${HOME}/Stuff/Local/Downloads/usenet"
paths[4]="${HOME}/MergerFS"
paths[5]="${HOME}/scripts"

#Checks

if [ ! -f "${HOME}/bin/rclone" ]; then
    echo "rclone is not installed."
    echo "Install rclone stable, then run the script again. https://docs.usbx.me/link/6#bkmrk-rclone-stable"
    echo "Also, do not forget to configure your rclone remote."
    exit 1
fi

if [ ! -f "${HOME}/bin/mergerfs" ]; then
    echo "mergerfs is not installed."
    echo "Install mergerfs, then run the script again. https://docs.usbx.me/link/344#bkmrk-preparation"
    exit 1
fi

rclone selfupdate -q

read -rp "Enter the rclone remote name for your Google Drive: " remote
if ! rclone lsd "${remote}:" >>/dev/null; then
    echo "Configure your rclone remote correctly, then run the script again. https://docs.usbx.me/link/6#bkmrk-rclone"
    exit 1
fi

for i in {1..5}; do
    if [ ! -d "${paths[${i}]}" ]; then
        mkdir -p "${paths[${i}]}"
    fi
done

#Install systemd services

cat <<EOF | tee "${HOME}/.config/systemd/user/rclone-vfs.service" >/dev/null
[Unit]
Description=RClone VFS Service
Wants=network-online.target
After=network-online.target

[Service]
Type=notify
TimeoutStopSec=60
Environment=GOMAXPROCS=2

ExecStart=%h/bin/rclone mount ${remote}: %h/Stuff/Mount \
  --config %h/.config/rclone/rclone.conf \
  --use-mmap \
  --dir-cache-time 1000h \
  --poll-interval=15s \
  --vfs-cache-mode writes \
  --tpslimit 10

StandardOutput=file:%h/scripts/rclone_vfs_mount.log
ExecStop=/bin/fusermount -uz %h/Stuff/Mount
Restart=on-failure

[Install]
WantedBy=default.target
EOF

cat <<EOF | tee "${HOME}/.config/systemd/user/mergerfs.service" >/dev/null
[Unit]
Description = MergerFS Service
After=rclone-vfs.service
RequiresMountsFor=%h/Stuff/Local
RequiresMountsFor=%h/Stuff/Mount

[Service]
Type=forking
TimeoutStopSec=60
ExecStart=%h/bin/mergerfs \
    -o use_ino,func.getattr=newest,category.action=all \
    -o category.create=ff,cache.files=auto-full,threads=8 \
    %h/Stuff/Local:%h/Stuff/Mount %h/MergerFS

StandardOutput=file:%h/scripts/mergerfs_mount.log
ExecStop=/bin/fusermount -uz %h/MergerFS
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now --quiet rclone-vfs.service mergerfs.service
sleep 5

mdkir -p "${HOME}/MergerFS/Movies"
mdkir -p "${HOME}/MergerFS/TV Shows"

#Install rclone-upload.sh

cat <<EOF | tee "${HOME}/scripts/rclone-upload.sh" >/dev/null
#!/bin/bash

lock_file="\$HOME/scripts/rclone-upload.lock"

trap 'rm -f "\$lock_file"; exit 0' SIGINT SIGTERM
if [ -e "\$lock_file" ]
then
    echo "Rclone upload script is already running."
    exit
else
    rm "\$HOME"/scripts/rclone-upload.log
    touch "\$lock_file"
    "\$HOME"/bin/rclone move "\$HOME"/Stuff/Local/ ${remote}: \\
        --config="\$HOME"/.config/rclone/rclone.conf \\
        --exclude "Downloads/**" \\
        --drive-chunk-size 64M \\
        --tpslimit 5 \\
        -vvv \\
        --drive-stop-on-upload-limit \\
        --delete-empty-src-dirs \\
        --bwlimit=8M \\
        --use-mmap \\
        --transfers=2 \\
        --checkers=4 \\
        --log-file "\$HOME"/scripts/rclone-upload.log
    rm -f "\$lock_file"
    trap - SIGINT SIGTERM
    exit
fi
EOF

chmod +x "${HOME}/scripts/rclone-upload.sh"

#Install rclone-upload cronjob

croncmd="$HOME/scripts/rclone-upload.sh > /dev/null 2>&1"
cronjob="0 19 * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" || : ; echo "$cronjob" ) | crontab -

echo "Work flow set up complete. Continue following the guide."
