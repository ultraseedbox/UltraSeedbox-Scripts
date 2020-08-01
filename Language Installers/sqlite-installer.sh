#!/bin/bash

# SQlite3 installer for USB Slots by Xan#7777
# This compiles and installs sqlite3 to your slot

clear
echo "This is the sqlite3 Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

if [ ! -f "$HOME"/bin/sqlite3 ]; then
    mkdir -p "$HOME"/.sqlite-tmp
    cd "$HOME"/.sqlite-tmp || exit
    wget https://www.sqlite.org/2020/sqlite-autoconf-3320300.tar.gz
    tar xvfz sqlite-autoconf-3320300.tar.gz
    cd "$HOME"/.sqlite-tmp/sqlite-autoconf-3320300 || exit
    ./configure --prefix="$HOME"
    make
    make install
    cd "$HOME" || exit
    rm -rfv "$HOME"/.sqlite-tmp
    exit 0
else
    echo "Sqlite3 is already installed!"
    exit 1
fi