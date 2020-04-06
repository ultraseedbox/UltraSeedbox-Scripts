#!/bin/bash

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE="en_US.UTF-8"

TORRENT_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"
TORRENT_NAME="$TR_TORRENT_NAME"
TORRENT_LABEL="N/A"

# Subtitle language
SUBLANG=en
SKIP_EXTRACT=y
MUSIC=y

"$HOME"/bin/filebot -script fn:amc \
    --output "$HOME/media" \
        -non-strict --encoding utf8 --log all --log-file amc-transmission.log --action symlink --conflict override \
        --def artwork=false ut_kind=multi "ut_dir=$TORRENT_PATH" "ut_title=$TORRENT_NAME" subtitles=$SUBLANG \
        extractFolder="$HOME/files/_extracted" music=$MUSIC skipExtract=$SKIP_EXTRACT &