#!/bin/bash

# Python 3 and Pip Installer for USB Slots by Xan#7777
# This installs python 3 and pip on your slot using pyenv
# After installing, close your SSH and login again for profile to properly load.

# Unofficial Script warning
clear
echo "This is the Python and PIP Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -rp "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Variables
python="$HOME"/.pyenv/shims/python

# Install pyenv
clear
echo "Installing pyenv..."
sleep 1
curl https://pyenv.run | bash

# Add pyenv to bashrc
echo 'export PATH="/homexx/yyyyy/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"' >> "$HOME"/.bashrc
sed -i "s|\/homexx\/yyyyy|$HOME|g" "$HOME"/.bashrc

# Load new bashrc
source "$HOME"/.bashrc

# Install xxenv-latest
git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/pyenv-latest

# Python Version Chooser
clear
echo "Choose between '3.6', '3.7' or 'latest'."
echo "We recommend entering '3.7' as your Python version."
echo "You can also type 'quit' to quit the installer."

while true; do
    read -rp "Enter your response here: " pyver
    case $pyver in
        3.6 ) pyenv latest install 3.6 -v && break ;;
        3.7 ) pyenv latest install 3.7 -v && break ;;
        latest ) pyenv latest install -v && break ;;
        quit ) exit 0 ;;
        * ) echo "Unknown response. Try again..." ;;
    esac
done

# Check Python
clear
pyenv latest global
echo "Getting python version..."
command -v python
sleep 2

# Installing pip
clear
echo "Installing pip..."
"$python" <(curl https://bootstrap.pypa.io/get-pip.py) --user

# Replacing PATH
sed -i -e 's|PATH="$HOME/bin:$PATH"|PATH="$HOME/bin:$HOME/.local/bin:$PATH"|g' "$HOME"/.profile

# Reload new profile
source "$HOME"/.profile

# Cleanup, reload shell and Exit
clear
echo "Done. Please logout and login again into your shell to complete installation."
exit 1