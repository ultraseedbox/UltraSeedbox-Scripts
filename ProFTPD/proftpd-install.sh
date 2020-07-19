#!/bin/bash

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

PORT=$(( 11000 + (($UID - 1000) * 50) + 13))

read -p "FTP Root Folder: " ROOT
ROOT="${ROOT/#\~/$HOME}"

echo "Installing ProFTPD..."

mkdir -p $ROOT
mkdir -p ~/.config/proftpd

echo "User                    $USER
Group                   $USER
Port                    $PORT
PassivePorts            5000 9999
Umask                   022
MaxInstances            10
DefaultServer           on
AuthPAM                 off
AuthUserFile            $HOME/.config/proftpd/proftpd.passwd
PidFile                 $HOME/.config/proftpd/proftpd.pid
ScoreboardFile          $HOME/.config/proftpd/proftpd.scoreboard
DelayTable              $HOME/.config/proftpd/proftpd.delay
SystemLog               $HOME/.config/proftpd/proftpd.log
TransferLog             None
WtmpLog                 None
DefaultChdir            $ROOT" > ~/.config/proftpd/proftpd.conf

echo "Configuring Authentication..."

input="y"
while [ "$input" = "y" ]
do
  read -p "Username: " username
  read -s -p "Password: " password
  echo "$password" | /usr/sbin/ftpasswd --passwd --stdin --file="$HOME/.config/proftpd/proftpd.passwd" --name=$username --uid=$UID --home=$ROOT --shell=$SHELL --gid=$(id -g $USER)
  read -p "Do you want to create another user? (y/n) " input
done

chmod o-rwx ~/.config/proftpd/proftpd.passwd

echo "
<Limit ALL>
    DenyAll
</Limit>

<Directory $ROOT>
    <Limit ALL>
        AllowAll
    </Limit>
</Directory>" >> ~/.config/proftpd/proftpd.conf

echo "Installing Service..."

echo "#!/bin/bash
/usr/sbin/proftpd -c ~/.config/proftpd/proftpd.conf &> /dev/null" > ~/.config/proftpd/start
chmod +x ~/.config/proftpd/start

echo "[Unit]
Description=ProFTPD
After=network.target

[Service]
Type=forking
PIDFile=$HOME/.config/proftpd/proftpd.pid
ExecStart=$HOME/.config/proftpd/start
ExecReload=/bin/kill -HUP \$MAINPID
ExecStop=/bin/kill \$MAINPID

[Install]
WantedBy=default.target" > ~/.config/systemd/user/proftpd.service

systemctl --user daemon-reload
systemctl --user enable proftpd

loginctl enable-linger $USER

echo "Configuring TLS..."

openssl genrsa -out ~/.config/proftpd/server.key 1024
openssl req -new -key ~/.config/proftpd/server.key -out ~/.config/proftpd/server.csr -subj "/C=NL/ST=NH/L=Amsterdam/O=Ultraseedbox/CN=$(hostname).usbx.me"
openssl x509 -req -days 365 -in ~/.config/proftpd/server.csr -signkey ~/.config/proftpd/server.key -out ~/.config/proftpd/server.crt

echo "
LoadModule mod_tls.c
TLSEngine on
TLSProtocol TLSv1.2
TLSRequired on
TLSRSACertificateFile $HOME/.config/proftpd/server.crt
TLSRSACertificateKeyFile $HOME/.config/proftpd/server.key
TLSVerifyClient off" >> ~/.config/proftpd/proftpd.conf

echo "Starting ProFTPD..."

systemctl --user start proftpd

echo "Downloading Scripts..."
cd ~
wget -q https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/ProFTPD/proftpd-uninstall.sh
chmod +x proftpd-uninstall.sh
wget -q https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/ProFTPD/proftpd-users.sh
chmod +x proftpd-users.sh

printf "\033[0;32mDone!\033[0m\n"
echo "Access your ProFTPD installation at ftp://$(hostname).usbx.me:$PORT"
echo "Run ./proftpd-uninstall.sh to uninstall | Run ./proftpd-users.sh to manage users"