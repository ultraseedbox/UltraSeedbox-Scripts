#!/bin/sh

# Flexget Installer by Xan#7777
# This installs flexget under python-venv

# Unofficial Script warning
clear
echo "This is Flexget Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Python Check
clear
echo "Checking your python version..."
sleep 1
if python -V | grep -q 3.[6-8].[0-9];
then
    echo "Required python version detected. Continuing..."
else
    echo "Please install Python versions 3.6 and above."
    exit 0
fi

# Install Flexget
clear
echo "Installing flexget..."
sleep 1
python -m venv "$HOME"/flexget/
cd "$HOME"/flexget || exit
"$HOME"/flexget/bin/pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 "$HOME"/flexget/bin/pip install -U 
"$HOME"/flexget/bin/pip install wheel
"$HOME"/flexget/bin/pip install flexget --upgrade
ln -s "$HOME"/flexget/bin/flexget "$HOME"/bin/flexget

# Check flexget
clear
command -v flexget
flexget --version
sleep 1

# Cleanup and exit
clear
echo "Done. You can now create your flexget YAML"
exit 1