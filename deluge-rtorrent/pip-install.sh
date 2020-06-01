#!/bin/bash

# PIP Installer for USB Slots by Xan#7777
# After installing, close your SSH and login again for profile to properly load.

echo "Installing pip..."

# Running PIP Installer
python3 <(curl https://bootstrap.pypa.io/get-pip.py) --user

# Replacing PATH
sed -i -e 's|PATH="$HOME/bin:$PATH"|PATH="$HOME/bin:$HOME/.local/bin:$PATH"|g' "$HOME"/.profile

# Echoes and Script Cleanup
echo "Done."
echo "You need to close your SSH session and login into your SSH again after."
sleep 5
rm -- "$0"
exit