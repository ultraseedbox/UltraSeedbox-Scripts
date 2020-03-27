#!/bin/sh -xu
# Based on the official tar installer: https://raw.githubusercontent.com/filebot/plugins/master/installer/tar.sh

PACKAGE_VERSION=4.8.5
PACKAGE_SHA256=$(curl -fsSL https://raw.githubusercontent.com/filebot/website/master/get.filebot.net/filebot/FileBot_$PACKAGE_VERSION/FileBot_$PACKAGE_VERSION-portable.tar.xz.sha256)

PACKAGE_FILE=FileBot_$PACKAGE_VERSION-portable.tar.xz
PACKAGE_URL=https://get.filebot.net/filebot/FileBot_$PACKAGE_VERSION/$PACKAGE_FILE

# Download latest portable package
curl -o "$PACKAGE_FILE" -z "$PACKAGE_FILE" "$PACKAGE_URL"

# Check SHA-256 checksum
echo "$PACKAGE_SHA256 *$PACKAGE_FILE" | sha256sum --check || exit 1

# Extract *.tar.xz archive
tar xvf "$PACKAGE_FILE"

# Increase maximum amount of memory that can be allocated to the JVM heap
sed -i '/#!\/bin\/sh/a export JAVA_OPTS=\"-Xmx1536m\"' filebot.sh

# Check if filebot.sh works
"$PWD/filebot.sh" -script https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/FileBot/usbsysinfo.groovy

# Link into user $PATH
ln -sf "$PWD/filebot.sh" $HOME/bin/filebot

# Check if the filebot command works
filebot -version
