#!/bin/bash

# megatools installer/updater/uninstaller by Xan#7777

# Unofficial Script warning
clear
echo "This is the megatools Installer!"
echo ""
printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

megalatest=1.10.3
megacompla=$(echo "$megalatest" | sed 's/\.//g')
megacompver=$(megadl --version | awk {'print $2'} | grep "1.10.[1-3]" | sed 's/\.//g')

# Create temp folder
mkdir -p "$HOME"/.megatools-tmp
cd "$HOME"/.megatools-tmp || exit

# Main Menu
clear
echo "What do you want to do?"
echo "Type '1' to install megatools."
echo "Type '2' to upgrade megatools."
echo "Type '3' to uninstall megatools."
echo "Type 'exit' to exit the installer."

while true; do
    read -rp "Enter your response here: " mega
    case $mega in
        1)
            if [ ! "$(megadl --version)" ]; then
                clear
                echo "Installing megatools..."
                sleep 2
                wget -qO megatools.tar.gz "https://megatools.megous.com/builds/megatools-$megalatest.tar.gz"
                tar xf megatools.tar.gz
                cd "$HOME"/.megatools-tmp/megatools-"$megalatest"/ || exit
                ./configure --prefix="$HOME" --disable-docs
                make
                make install
                clear
                echo "Installation complete!"
                sleep 1
            else
                echo "You already installed megatools!"
                sleep 2
            fi
            break
            ;;
        2)
            clear
            if [ "$(megadl --version)" ]; then
                if [[ "$megacompla" > "$megacompver" ]]; then
                    echo "Upgrading megatools..."
                    sleep 2
                    rm -rf "$HOME"/bin/{megacopy,megadf,megadl,megaget,megals,megamkdir,megaput,megareg,megarm}
                    wget -qO megatools.tar.gz "https://megatools.megous.com/builds/megatools-$megalatest.tar.gz"
                    tar xf megatools.tar.gz
                    cd "$HOME"/.megatools-tmp/megatools-"$megalatest"/ || exit
                    ./configure --prefix="$HOME" --disable-docs
                    make
                    make install
                    echo "megatools upgrade complete!"
                elif [[ "$megacompla" == "$megacompver" ]]; then
                    echo "You are on the latest version! Exiting..."
                    sleep 2
                elif [[ ! "$megacompla" > "$megacompver" ]]; then
                    echo "Your megatools version is too old."
                    echo "Run this installer and choose uninstall."
                    echo "Then, run the installer again to install."
                    sleep 2
                fi
            else
                clear
                echo "You haven't installed megatools."
                sleep 2
            fi
            break
            ;;
        3)
            clear
            if [ "$(megadl --version)" ]; then
                echo "Uninstalling megatools..."
                sleep 2
                rm -rf "$HOME"/bin/{megacopy,megadf,megadl,megaget,megals,megamkdir,megaput,megareg,megarm}
                break
            else
                clear
                echo "You already uninstalled megatools."
                sleep 2
                break
            fi
            ;;
        exit)
            break
            ;;
        * ) echo "Unknown response. Try again..." ;;
    esac
done

# cleanup
clear
cd "$HOME" || exit
rm -rf "$HOME"/.megatools-tmp
echo "Goodbye."
exit