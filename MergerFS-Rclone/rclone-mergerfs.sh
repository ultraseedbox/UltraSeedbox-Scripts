#!/bin/bash

set -euo pipefail

#Disclaimer

printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
  exit
fi
echo

declare -a paths
paths[1]="${HOME}/Stuff/Mount"
paths[2]="${HOME}/Stuff/Local/Downloads/torrents"
paths[3]="${HOME}/Stuff/Local/Downloads/usenet"
paths[4]="${HOME}/MergerFS"
paths[5]="${HOME}/scripts"
paths[6]="${HOME}/Stuff/Local/Movies"
paths[7]="${HOME}/Stuff/Local/TV Shows"

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

if [[ -n $(ls -A "${paths[1]}") || -n $(ls -A "${paths[4]}") ]]; then
  echo
  echo "ERROR: ${paths[1]} or ${paths[4]} is not empty."
  echo "Please stop all running rclone/mergerfs mount processes, and run the script again."
  echo "If data is stored locally in above paths, move the data out of these directories and then run the script again."
  echo "Both of them must be empty for the rclone and mergerfs mounts to work properly."
  echo
  exit 1
fi

if ! rclone selfupdate --version 1.61.1 -q > /dev/null 2>&1; then
  echo "Self-update failed. Installed rclone version is very old."
  echo "Install rclone stable, then run the script again. https://docs.usbx.me/link/6#bkmrk-rclone-stable"
  exit 1
fi

read -rp "Enter the rclone remote name for your Google Drive: " remote
echo
if ! rclone lsd "${remote}:" >>/dev/null; then
  echo "Configure your rclone remote correctly, then run the script again. https://docs.usbx.me/link/6#bkmrk-rclone"
  exit 1
fi

echo "Select type of rclone upload script [ Choose from 1 - 3 ]: "

select upload in Normal Discord-Notification Quit; do
  case ${upload} in
  Normal)
    upload="normal"
    break
    ;;
  Discord-Notification)
    upload="discord"
    echo
    read -rp "Enter the Discord Webhook URL: " webhook
    break
    ;;
  Quit)
    exit 0
    ;;
  *)
    echo "Invalid option ${REPLY}"
    ;;
  esac
done
echo
echo "Rclone-MergerFS workflow setup started.."

for i in {1..7}; do
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

ExecStart=%h/bin/rclone mount ${remote}: %h/Stuff/Mount \\
  --config %h/.config/rclone/rclone.conf \\
  --use-mmap \\
  --dir-cache-time 1000h \\
  --poll-interval=15s \\
  --vfs-cache-mode writes \\
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
ExecStart=%h/bin/mergerfs \\
    -o use_ino,func.getattr=newest,category.action=all \\
    -o category.create=ff,cache.files=auto-full,threads=8 \\
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

#Install rclone-upload script

if [ "${upload}" == "discord" ]; then
  cat <<EOF | tee "${HOME}/scripts/rclone-upload.sh" >/dev/null
#!/bin/bash

# Rclone upload script with optional Discord notification upon move completion (if something is moved)
#
# Recommended for use via cron
# For example: */10 * * * * /path/to/rclone-upload.sh >/dev/null 2>&1
# -----------------------------------------------------------------------------

SOURCE_DIR="\$HOME/Stuff/Local/"
DESTINATION_DIR="${remote}:"

DISCORD_WEBHOOK_URL="${webhook}"
DISCORD_ICON_OVERRIDE="https://i.imgur.com/MZYwA1I.png"
DISCORD_NAME_OVERRIDE="RCLONE"

LOCK_FILE="\$HOME/scripts/rclone-upload.lock"
LOG_FILE="\$HOME/scripts/rclone-upload.log"

# DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING
# -----------------------------------------------------------------------------

trap 'rm -f \$LOCK_FILE; exit 0' SIGINT SIGTERM
if [ -e "\$LOCK_FILE" ]
then
  echo "\$0 is already running."
  exit
else
  if [ -f "\$LOG_FILE" ]
  then
       rm "\$LOG_FILE"
  fi
  touch "\$LOCK_FILE"
  
  rclone_move() {
    rclone_command=\$(
      "\$HOME"/bin/rclone move -vP \\
      --config="\$HOME"/.config/rclone/rclone.conf \\
      --exclude "Downloads/**" \\
      --drive-chunk-size 64M \\
      --use-mmap \\
      --delete-empty-src-dirs \\
      --log-file="\$LOG_FILE" \\
      --stats=9999m \\
      --tpslimit=5 \\
      --transfers=2 \\
      --checkers=4 \\
      --bwlimit=8M \\
      --drive-stop-on-upload-limit \\
      "\$SOURCE_DIR" "\$DESTINATION_DIR" 2>&1
    )
    # "--stats=9999m" mitigates early stats output 
    # "2>&1" ensures error output when running via command line
    echo "\$rclone_command"
  }
  rclone_move

  if [ "\$DISCORD_WEBHOOK_URL" != "" ]; then
  
    rclone_sani_command="\$(echo \$rclone_command | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')" # Remove all escape sequences

    # Notifications assume following rclone ouput: 
    # Transferred: 0 / 0 Bytes, -, 0 Bytes/s, ETA - Errors: 0 Checks: 0 / 0, - Transferred: 0 / 0, - Elapsed time: 0.0s

    transferred_amount=\${rclone_sani_command#*Transferred: }
    transferred_amount=\${transferred_amount%% /*}
    
    send_notification() {
      output_transferred_main=\${rclone_sani_command#*Transferred: }
      output_transferred_main=\${output_transferred_main% Errors*}
      output_errors=\${rclone_sani_command#*Errors: }
      output_errors=\${output_errors% Checks*}
      output_checks=\${rclone_sani_command#*Checks: }
      output_checks=\${output_checks% Transferred*}
      output_transferred=\${rclone_sani_command##*Transferred: }
      output_transferred=\${output_transferred% Elapsed*}
      output_elapsed=\${rclone_sani_command##*Elapsed time: }
      
      notification_data='{
        "username": "'"\$DISCORD_NAME_OVERRIDE"'",
        "avatar_url": "'"\$DISCORD_ICON_OVERRIDE"'",
        "content": null,
        "embeds": [
          {
            "title": "Rclone Upload Task: Success!",
            "color": 4094126,
            "fields": [
              {
                "name": "Transferred",
                "value": "'"\$output_transferred_main"'"
              },
              {
                "name": "Errors",
                "value": "'"\$output_errors"'"
              },
              {
                "name": "Checks",
                "value": "'"\$output_checks"'"
              },
              {
                "name": "Transferred",
                "value": "'"\$output_transferred"'"
              },
              {
                "name": "Elapsed time",
                "value": "'"\$output_elapsed"'"
              }
            ],
            "thumbnail": {
              "url": null
            }
          }
        ]
      }'
      
      /usr/bin/curl -H "Content-Type: application/json" -d "\$notification_data" \$DISCORD_WEBHOOK_URL 
    }
    
    if [ "\$transferred_amount" != "0 B" ]; then
      send_notification
    fi

  fi

  rm -f "\$LOCK_FILE"
  trap - SIGINT SIGTERM
  exit
fi
EOF
else
  cat <<EOF | tee "${HOME}/scripts/rclone-upload.sh" >/dev/null
#!/bin/bash

lock_file="\$HOME/scripts/rclone-upload.lock"

trap 'rm -f "\$lock_file"; exit 0' SIGINT SIGTERM
if [ -e "\$lock_file" ]
then
    echo "Rclone upload script is already running."
    exit
else
    if [ -f "\$HOME"/scripts/rclone-upload.log ]
    then
        rm "\$HOME"/scripts/rclone-upload.log
    fi
    touch "\$lock_file"
    "\$HOME"/bin/rclone move -P "\$HOME"/Stuff/Local/ ${remote}: \\
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
fi

chmod +x "${HOME}/scripts/rclone-upload.sh"

#Install rclone-upload cronjob

croncmd="${HOME}/scripts/rclone-upload.sh > /dev/null 2>&1"
cronjob="0 19 * * * $croncmd"
(
  crontab -l 2>/dev/null | grep -v -F "$croncmd" || :
  echo "$cronjob"
) | crontab -

echo "Work flow set up complete. Continue following the guide."