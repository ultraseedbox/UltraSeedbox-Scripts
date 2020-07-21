#!/bin/bash

lock_file="$HOME/scripts/rclone-upload.lock"

trap 'rm -f "$lock_file"; exit 0' SIGINT SIGTERM
if [ -e "$lock_file" ]
then
    echo "Rclone upload script is already running."
    exit
else
    rm "$HOME"/scripts/rclone-upload.log
    touch "$lock_file"
    "$HOME"/bin/rclone move "$HOME"/Stuff/Local/ gdrive: --user-agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36' --config="$HOME"/.config/rclone/rclone.conf --drive-chunk-size 64M --tpslimit 5 --drive-acknowledge-abuse=true -vvv --drive-stop-on-upload-limit --delete-empty-src-dirs --fast-list --bwlimit=8M --use-mmap --transfers=2 --checkers=4 --log-file "$HOME"/scripts/rclone-upload.log
    rm -f "$lock_file"
    trap - SIGINT SIGTERM
    exit
fi