#!/bin/sh

# Filebot 4.8.5 Installer by tylerforesthauser#9004 and Xan#7777
# Based on the official tar installer: https://raw.githubusercontent.com/filebot/plugins/master/installer/tar.sh
# Includes OpenJDK 11 LTS Installer

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
    exit
fi

# Set FileBot version and URLs
PACKAGE_VERSION=4.8.5
PACKAGE_SHA256=$(curl -fsSL https://raw.githubusercontent.com/filebot/website/master/get.filebot.net/filebot/FileBot_$PACKAGE_VERSION/FileBot_$PACKAGE_VERSION-portable.tar.xz.sha256)
PACKAGE_FILE=FileBot_$PACKAGE_VERSION-portable.tar.xz
PACKAGE_URL=https://get.filebot.net/filebot/FileBot_$PACKAGE_VERSION/$PACKAGE_FILE

# Create directory for all FileBot data and change working directory
mkdir -p "$HOME"/filebot-485 && cd "$HOME"/filebot-485 || exit

# Fetch OpenJDK 11 binaries archive
curl -o Java11.tar.gz "https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz"

# Extract OpenJDK 11 binaries and remove archive
tar xf Java11.tar.gz && rm Java11.tar.gz

# Download latest portable package
curl -o "$PACKAGE_FILE" -z "$PACKAGE_FILE" "$PACKAGE_URL"

# Check SHA-256 checksum
echo "$PACKAGE_SHA256 *$PACKAGE_FILE" | sha256sum --check || exit 1

# Extract *.tar.xz archive
tar xvf "$PACKAGE_FILE"

# Increase maximum amount of memory that can be allocated to the JVM heap
sed -i '/#!\/bin\/sh/a export JAVA_OPTS=\"-Xmx1536m\"' filebot.sh

# Use custom OpenJDK 11 installation to run FileBot
sed -i '/^java/ s#java#'"$PWD"'\/jdk-11\/bin\/java#' filebot.sh

# Check if filebot.sh works
"$PWD/filebot.sh" -script https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/FileBot/usbsysinfo.groovy

# Link into user $PATH
ln -sf "$PWD/filebot.sh" "$HOME"/bin/filebot

# Check if the filebot command works and exit
filebot -version
exit