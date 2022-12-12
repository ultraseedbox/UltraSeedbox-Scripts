#!/bin/bash
# MergerFS Installer/Updater by Xan#7777 & Raikiri

if pgrep "mergerfs"; then
    echo "mergerfs is running. Please close all mergerfs instances before proceeding."
    exit 0
fi
clear

#Check Debian Version

lsb_release -d | grep -q 10 && debversion="buster" || debversion="stretch"

default_version="2.33.5"

echo "Select version of mergerfs to install. [ Choose from 1 - 3 ]: "

select version in ${default_version} Latest Quit; do
    case ${version} in
    $default_version)
        version="${default_version}"
        break
        ;;
    Latest)
        LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/trapexit/mergerfs/releases/latest)
        LATEST_VERSION=$(echo "$LATEST_RELEASE" | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
        version="$LATEST_VERSION"
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
clear
if [ "${version}" = "${default_version}" ]; then
    echo "mergerfs is installing/upgrading..."
    mkdir -p "$HOME"/.mergerfs-tmp/
    wget "https://github.com/trapexit/mergerfs/releases/download/${version}/mergerfs_${version}.debian-${debversion}_amd64.deb" -O "$HOME"/.mergerfs-tmp/mergerfs.deb
    rm -rf "$HOME"/bin/*mergerfs*
    dpkg -x "$HOME"/.mergerfs-tmp/mergerfs.deb "$HOME"/.mergerfs-tmp
    cp "$HOME"/.mergerfs-tmp/usr/bin/* "$HOME"/bin
else
    echo "mergerfs is installing/upgrading..."
    mkdir -p "$HOME"/.mergerfs-tmp/
    wget "https://github.com/trapexit/mergerfs/releases/download/${version}/mergerfs_${version}.debian-${debversion}_amd64.deb" -O "$HOME"/.mergerfs-tmp/mergerfs.deb || {
        echo "Asset for mergerfs version ${version} not found. Try installing ${default_version} by running the script again."
        rm -rf "$HOME"/.mergerfs-tmp
        exit 1
    }
    rm -rf "$HOME"/bin/*mergerfs*
    dpkg -x "$HOME"/.mergerfs-tmp/mergerfs.deb "$HOME"/.mergerfs-tmp
    cp "$HOME"/.mergerfs-tmp/usr/bin/* "$HOME"/bin
fi

clear

if [[ $("$HOME"/bin/mergerfs -V) ]]; then
    echo "MergerFS installed correctly! Restart your SSH session to properly apply changes!"
    rm -rf "$HOME"/.mergerfs-tmp
    exit 0
else
    echo "$version"
    echo "mergerfs install somehow failed. Please run this again!"
    rm -rf "$HOME"/.mergerfs-tmp
    exit 1
fi
exit
