#!/bin/bash

# Python 3 and Pip Installer for USB Slots by Xan#7777
# This installs python 3, pip and pyenv on your slot using pyenv
# After installing, close your SSH and login again for profile to properly load.

# Unofficial Script warning
clear
echo "This is the Python and PIP Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Install pyenv

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
echo "Choose between 3.6, 3.7 or latest."
echo "We recommend entering 3.7 as your Python version."

while true; do
read -p "Enter your response here: " pyver
    case $pyver in
        3.6)
            "$HOME"/.pyenv/bin/pyenv latest install 3.6 -v
            break
            ;;
        3.7)
            "$HOME"/.pyenv/bin/pyenv latest install 3.7 -v
            break
            ;;
        latest)
            "$HOME"/.pyenv/bin/pyenv latest install -v
            break
            ;;
        *) echo "Unknown response. Try again..." ;;
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
"$(command -v python)" -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 "$(command -v python)" -m pip install -U

# Replacing PATH
sed -i -e 's|PATH="$HOME/bin:$PATH"|PATH="$HOME/bin:$HOME/.local/bin:$PATH"|g' "$HOME"/.profile

# Reload new profile
source "$HOME"/.profile

# Cleanup, reload shell and Exit
clear
echo "Done. Run the following command to properly load up your Python/Pip Install."
echo "               exec $SHELL                 "
exit