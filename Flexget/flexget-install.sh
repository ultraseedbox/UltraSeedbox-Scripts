#!/bin/bash

# Flexget Installer/Updater by Xan#7777
# This installs/updates flexget under python-venv

# Unofficial Script warning
clear
echo "This is Flexget Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
    exit
fi

# Install Flexget
clear
echo "Installing flexget..."
sleep 1
if [ ! -d "$HOME"/flexget/ ]; then
    /usr/bin/python3 -m venv "$HOME"/flexget/
fi
"$HOME"/flexget/bin/pip3 install --ignore-installed --no-cache-dir pip
"$HOME"/flexget/bin/pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 "$HOME"/flexget/bin/pip install -U
"$HOME"/flexget/bin/pip install --no-cache-dir wheel --upgrade
"$HOME"/flexget/bin/pip install --no-cache-dir flexget --upgrade
if [ ! -f "$HOME"/bin/flexget ]; then
    ln -s "$HOME"/flexget/bin/flexget "$HOME"/bin/flexget
fi

# Check flexget
clear
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo
echo "Flexget installed."
echo "Path: $(command -v flexget)"
echo "Flexget Version: $(flexget --version)"
echo
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo

# Client Installer
echo "You may need to install a client that can interface with your actual torent client."
echo "Choose between deluge or transmission. You may also skip if you do not need it."
echo
echo "Choose [ 1 - 3 ] :"

select flexent in Deluge Transmission Skip; do

    case ${flexent} in
    Deluge)
        "$HOME"/flexget/bin/python -m pip install deluge-client --upgrade
        echo "Refer to this page for more info: https://flexget.com/Plugins/deluge"
        sleep 7
        break
        ;;
    Transmission)
        "$HOME"/flexget/bin/python -m pip install transmissionrpc --upgrade
        echo "Refer to this page for more info: https://flexget.com/Plugins/transmission"
        sleep 7
        break
        ;;
    Skip)
        break
        ;;
    *)
        echo "Invalid option $REPLY."
        ;;
    esac
done

# Cleanup and exit
clear
echo "Done. You can now create your flexget YAML."
exit