#!/bin/sh

# Flexget Installer/Updater by Xan#7777
# This installs/updates flexget under python-venv

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
if [ ! -d "$HOME"/flexget/ ]; then
    python -m venv "$HOME"/flexget/
fi
"$HOME"/flexget/bin/pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 "$HOME"/flexget/bin/pip install -U 
"$HOME"/flexget/bin/pip install wheel --upgrade
"$HOME"/flexget/bin/pip install flexget --upgrade
if [ ! -f "$HOME"/bin/flexget ]; then
    ln -s "$HOME"/flexget/bin/flexget "$HOME"/bin/flexget
fi

# Check flexget
clear
command -v flexget
flexget --version
sleep 2

# Client Installer
clear
echo "You may need to install a client that can interface with your actual torent client."
echo "Choose between deluge or transmission. You may also skip if you do not need it."

while true; do
read -p "Enter your response here: " flexent
    case $flexent in
        deluge)
            "$HOME"/flexget/bin/python -m pip install deluge-client --upgrade
            echo "Refer to this page for more info: https://flexget.com/Plugins/deluge"
            sleep 7
            break
            ;;
        transmission)
            "$HOME"/flexget/bin/python -m pip install transmissionrpc --upgrade
            echo "Refer to this page for more info: https://flexget.com/Plugins/transmission"
            sleep 7
            break
            ;;
        skip)
            break
            ;;
        *) echo "Unknown response. Try again..." ;;
    esac
done

# Cleanup and exit
clear
echo "Done. You can now create your flexget YAML"
exit 1