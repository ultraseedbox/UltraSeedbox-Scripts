#!/bin/bash

# Python 3 and Pip Installer for USB Slots by Xan#7777
# This installs python 3, pip and pyenv on your slot using pyenv
# After installing, close your SSH and login again for profile to properly load.

# Unofficial Script warning
clear
echo "This is the Python and PIP Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -r -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Install pyenv

echo "Installing pyenv..."
sleep 1
curl https://pyenv.run | bash

# Add pyenv to bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile
echo 'eval "$(pyenv init --path)"' >> ~/.profile

# Load new bashrc
# shellcheck disable=SC1091
source "$HOME"/.bashrc
source "$HOME"/.profile

# Install xxenv-latest
git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/pyenv-latest

# Python Version Chooser
clear
echo "Choose between 3.6, 3.7, 3.8, or latest."
echo "1 = Python 3.6"
echo "2 = Python 3.7"
echo "3 = Python 3.8"
echo "4 = Python 3.10"
echo "5 = Latest Python 3 release"
echo "6 = Python 2.7"
echo "We recommend using Python 3.8 as your default Python version."

while true; do
read -r -p "Enter your response here: " pyver
    case $pyver in
        1)
            "$HOME"/.pyenv/bin/pyenv latest install 3.6 -v
            break
            ;;
        2)
            "$HOME"/.pyenv/bin/pyenv latest install 3.7 -v
            break
            ;;
        3)
            "$HOME"/.pyenv/bin/pyenv latest install 3.8 -v
            break
            ;;
        4)
            "$HOME"/.pyenv/bin/pyenv latest install 3.10 -v
            break
            ;;
        5)
            "$HOME"/.pyenv/bin/pyenv latest install -v
            break
            ;;
        5)
            "$HOME"/.pyenv/bin/pyenv latest install 2.7 -v
            break
            ;;
        *)
            echo "Unknown response. Try again..."
            ;;
    esac
done

# Check Python
clear
"$HOME"/.pyenv/bin/pyenv latest global
echo "Getting python version..."
command -v python
python -m pip -V
sleep 2

# Updating all pip packages

echo "Updating all pip packages..."
"$(command -v python)" -m pip list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 "$(command -v python)" -m pip install -U

# Replacing PATH
sed -i -e 's|PATH="$HOME/bin:$PATH"|PATH="$HOME/bin:$HOME/.local/bin:$PATH"|g' "$HOME"/.profile

# Reload new profile
# shellcheck disable=SC1091
source "$HOME"/.profile

# Cleanup, reload shell and Exit
clear
echo "Done. Run the following command to properly load up your Python/Pip Install."
echo "               exec $SHELL                 "
exit
