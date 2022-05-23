#!/bin/bash

# Python 3 and Pip Installer for Ultra.cc services by Xan#7777
# This installs python 3, pip and pyenv on your slot using pyenv

# Unofficial Script warning
clear
echo "This is the Python and PIP Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it\033[0m\n"
read -r -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]; then
    exit
fi

# Install pyenv

echo "Installing pyenv..."
sleep 1
curl https://pyenv.run | bash

# Add pyenv to .profile
# shellcheck disable=SC2016
grep -qxF 'export PYENV_ROOT="$HOME/.pyenv"' "${HOME}/.profile" || echo 'export PYENV_ROOT="$HOME/.pyenv"' >>"${HOME}/.profile"
# shellcheck disable=SC2016
grep -qxF 'export PATH="$PYENV_ROOT/bin:$PATH"' "${HOME}/.profile" || echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>"${HOME}/.profile"
# shellcheck disable=SC2016
grep -qxF 'eval "$(pyenv init --path)"' "${HOME}/.profile" || echo 'eval "$(pyenv init --path)"' >>"${HOME}/.profile"

# Load new profile
# shellcheck disable=SC1091
source "${HOME}/.profile"

# Install xxenv-latest
git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/pyenv-latest

# Python Version Chooser
clear
echo "Choose between 3.8, 3.9, 3.10, latest or 2.7."
echo "1 = Python 3.8"
echo "2 = Python 3.9"
echo "3 = Python 3.10"
echo "4 = Latest Python 3 release"
echo "5 = Python 2.7"
echo "We recommend using Python 3.8 as your default Python version."

while true; do
    read -r -p "Enter your response here: " pyver
    case $pyver in
    1)
        "$HOME"/.pyenv/bin/pyenv latest install 3.8 -v
        break
        ;;
    2)
        "$HOME"/.pyenv/bin/pyenv latest install 3.9 -v
        break
        ;;
    3)
        "$HOME"/.pyenv/bin/pyenv latest install 3.10 -v
        break
        ;;
    4)
        "$HOME"/.pyenv/bin/pyenv latest install -v
        break
        ;;
    5)
        "$HOME"/.pyenv/bin/pyenv latest install 2.7 -v
        break
        ;;
    *)
        echo "Invalid Option. Try again..."
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

#Cleanup and Exit
clear
echo "Done. Install successful."
echo "Please execute the SSH command given below to load your newly installed python."
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo "source ~/.profile"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
echo
exit