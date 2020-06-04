#!/bin/bash

# PIP Installer for USB Slots by Xan#7777
# After installing, close your SSH and login again for profile to properly load.

echo "Installing pip..."

# Running PIP Installer
python3 <(curl https://bootstrap.pypa.io/get-pip.py) --user

# Replacing PATH
sed -i -e 's|PATH="$HOME/bin:$PATH"|PATH="$HOME/bin:$HOME/.local/bin:$PATH"|g' "$HOME"/.profile

# Restarting Shell
exec $SHELL

# Cleanup
rm -- "$0"
exit