#!/bin/bash
set -e

#Disclaimer
printf "\033[0;31mDisclaimer: This installer is unofficial and Ultra.cc staff will not support any issues with it.\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

#Choose theme theme.park https://docs.theme-park.dev/themes/qbittorrent
echo "Choose Dark Theme:
1. Organizr Dark[Recommended]
2. Dark
3. Dracula
4. Overseerr"

read -p "Choice [default: 1]: " theme

case $theme in

  1)
    theme="organizr"
    ;;

  2)
    theme="dark"
    ;;

  3)
    theme="dracula"
    ;;

  4)
    theme="overseerr"
    ;;

  *)
    echo -n "Invalid choice. Installing default Organizr Dark Theme.."
    theme="organizr"
    ;;
esac

#Install theme
app-nginx stop
echo
port=$(app-ports show| grep qBittorrent | awk '{print $1}')
rm "$HOME"/.apps/nginx/proxy.d/qbittorrent.conf
wget -P "$HOME/.apps/nginx/proxy.d/" -q https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/qBittorrent/qbittorrent.conf
sed -i "s/>port</$port/g" "$HOME"/.apps/nginx/proxy.d/qbittorrent.conf
sed -i "s/>theme</$theme/g" "$HOME"/.apps/nginx/proxy.d/qbittorrent.conf
app-nginx restart

echo "qBittorrent $theme theme installed, visit at following URL:https://$USER.$HOSTNAME.usbx.me/qbittorrent"
exit
