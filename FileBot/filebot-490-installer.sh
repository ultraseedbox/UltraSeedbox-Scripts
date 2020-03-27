#!/bin/sh -xu
# Based on the official tar installer: https://raw.githubusercontent.com/filebot/plugins/master/installer/tar.sh
# Includes installer for Java 11, required to run FileBot 4.9+

# Set FileBot version and URLs
PACKAGE_VERSION=4.9.0
PACKAGE_SHA256=$(curl -fsSL https://raw.githubusercontent.com/filebot/website/master/get.filebot.net/filebot/FileBot_$PACKAGE_VERSION/FileBot_$PACKAGE_VERSION-portable.tar.xz.sha256)
PACKAGE_FILE=FileBot_$PACKAGE_VERSION-portable.tar.xz
PACKAGE_URL=https://get.filebot.net/filebot/FileBot_$PACKAGE_VERSION/$PACKAGE_FILE

# Create directory for all FileBot data and change working directory
mkdir -p "$HOME"/filebot-latest && cd "$HOME"/filebot-latest

# Fetch Java 11 binaries archive
curl -o Java11.tar.gz "https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz"

# Extract Java 11 binaries and remove archive
tar xf Java11.tar.gz && rm Java11.tar.gz

# Download FileBot package
curl -o "$PACKAGE_FILE" -z "$PACKAGE_FILE" "$PACKAGE_URL"

# Check SHA-256 checksum
echo "$PACKAGE_SHA256 *$PACKAGE_FILE" | sha256sum --check || exit 1

# Extract FileBot archive
tar xf "$PACKAGE_FILE"

# Clean up FileBot files
rm "$PACKAGE_FILE" reinstall-filebot.sh update-filebot.sh

# Increase maximum amount of memory that can be allocated to the JVM heap
sed -i '/#!\/bin\/sh/a export JAVA_OPTS=\"-Xmx1536m\"' filebot.sh

# Use custom Java 11 installation to run FileBot
sed -i '/^java/ s#java#'"$PWD"'\/jdk-11\/bin\/java#' filebot.sh

# Check if filebot.sh works
"$PWD/filebot.sh" -script https://raw.githubusercontent.com/no5tyle/UltraSeedbox-Scripts/master/FileBot/usbsysinfo.groovy

# Link into user bin
ln -sf "$PWD/filebot.sh" "$HOME"/bin/filebot

# Check if the filebot command works
filebot -version