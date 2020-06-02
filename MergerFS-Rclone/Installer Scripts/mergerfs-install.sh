#!/bin/bash

# MergerFS 2.28.3 Installer/Updater by Xan#7777

if pgrep "mergerfs";
then
    echo "mergerfs is running. Please close all mergerfs instances before proceeding."
    exit
else
    echo "mergerfs is installing/upgrading..."
    mkdir -p "$HOME"/tmp
    wget https://github.com/trapexit/mergerfs/releases/download/2.28.3/mergerfs_2.28.3.debian-stretch_amd64.deb -O "$HOME"/tmp/mergerfs.deb
    dpkg -x "$HOME"/tmp/mergerfs.deb "$HOME"/tmp
    mv "$HOME"/tmp/usr/bin/* "$HOME"/bin
    rm -rf "$HOME"/tmp
    command -v mergerfs
    mergerfs -v
fi
rm -- "$0"
exit