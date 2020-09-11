#!/bin/bash

# MergerFS Installer/Updater by Xan#7777

if pgrep "mergerfs";
then
    echo "mergerfs is running. Please close all mergerfs instances before proceeding."
    exit
else
    clear
    echo "mergerfs is installing/upgrading..."
    mkdir -p "$HOME"/.mergerfs-tmp/
    wget https://github.com/trapexit/mergerfs/releases/download/2.30.0/mergerfs_2.30.0.debian-stretch_amd64.deb -O "$HOME"/.mergerfs-tmp/mergerfs.deb
    dpkg -x "$HOME"/.mergerfs-tmp/mergerfs.deb "$HOME"/.mergerfs-tmp
    cp "$HOME"/.mergerfs-tmp/usr/bin/* "$HOME"/bin
fi

clear

if [[ $(mergerfs -v) ]]; then
    echo "MergerFS installed correctly!"
    rm -rf "$HOME"/.mergerfs-tmp
    exit 0
else
    echo "mergerfs install somehow failed. Please run this again!"
    rm -rf "$HOME"/.mergerfs-tmp
    exit 1
fi