#!/bin/bash

set -euo pipefail

#Check Python3 version

if ! python3 -V | grep -q -E "3.([6-9]|1[0-9]).*"  &&  ! /usr/bin/python3 -V | grep -q -E "3.([6-9]|1[0-9]).*"; then
 echo "Python3.6+ required to run."
 echo "Please install a python3 version greater than 3.6, then run this script again https://docs.usbx.me/books/pyenv/page/how-to-install-python-using-pyenv"
 exit 1
fi

#Set Python3 to be used

pythonbinary=$(which python3)

if /usr/bin/python3 -V | grep -q -E "3.([6-9]|1[0-9]).*";then
  pythonbinary="/usr/bin/python3"
fi

#Run the script

"${pythonbinary}" <(wget -qO- https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/Utility%20Scripts/Factory%20Reset/factor_reset.py)

exit 0