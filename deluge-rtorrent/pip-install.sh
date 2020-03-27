#!/bin/bash
echo "Installing pip..."
sleep 2
python3 <(curl https://bootstrap.pypa.io/get-pip.py) --user
sed -i -e 's#PATH="$HOME/bin:$PATH"#PATH="$HOME/bin:$HOME/.local/bin:$PATH"#g' $HOME/.profile
source $HOME/.profile
echo "Done."
echo "Installer needs to logout your SSH session to properly apply the changes."
echo "Please login to your slot's SSH again. Logging out..."
sleep 5
logout
exit