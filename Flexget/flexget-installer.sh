#!/bin/bash

# Flexget Installer by Xan#7777

echo "Installing PIP..."
python3 -m venv "$HOME"/flexget/
cd "$HOME"/flexget || exit
"$HOME"/flexget/bin/pip3 install pip --upgrade
"$HOME"/flexget/bin/pip3 install setuptools==45.2.0
"$HOME"/flexget/bin/pip3 install flexget
source "$HOME"/flexget/bin/activate

if command -v flexget ;
then
    echo "Flexget installed"
    sleep 1
    mkdir -p "$HOME"/.config/flexget
    flexget
    echo "If you need to use cron, the full path of flexget is"
    echo "$HOME/flexget/bin/flexget"
    echo "Make your first YAML by doing"
    echo "nano $HOME/.config/flexget/config.yml"
    exit
else
    echo "Flexget installation failed."
    echo "Please try again..."
    exit
fi