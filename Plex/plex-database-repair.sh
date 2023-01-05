#!/bin/bash
# by finch 
# bless xan & probbzy

# This is the repair function, could probably be cleaned up but works. 
repair()
{
    # Following guide per plexs instructions.
    echo "----------------------------------"
    echo "Repairing now with sqlite tools"
    echo "----------------------------------"
    sleep 2
    echo "Working in directory $HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/tmp"
    cd "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/" || exit
    sleep 2
    # Creating TMP directory for us to work in and moving the DB inside.
    mkdir tmp
    mv com.plexapp.plugins.library.db tmp/com.plexapp.plugins.library.db
    cd tmp || exit
    # Running repair commands
    # Clean up DB Before low level repair
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db "VACUUM;"
    sleep 1
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db "REINDEX;"
    # Starting Low Level Repair
    sleep 1
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db ".recover" | "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db-fixed
    sleep 1
    # Backup Cleaned Up Database before low level repair. 
    mkdir -p "$HOME"/plexbackup
    mv com.plexapp.plugins.library.db $HOME/plexbackup
    sleep 1
    # Rename back
    mv com.plexapp.plugins.library.db-fixed com.plexapp.plugins.library.db
    sleep 1
    # Moving the DB back to the main databases folder
    mv com.plexapp.plugins.library.db "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
    echo "----------------------------------"
    echo "Finished! Cleaning up!"
    echo "----------------------------------"
    # Clearing these files. These need to be according to plex but appears that they disappear on plex server stop. 
    rm -rf "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db-shm"
    rm -rf "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db-wal"
    # Moving into DB directory and removing the tmp work directory. 
    cd "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/" || exit
    rm -r "tmp"
    # Starting plex server again and exiting with good code. (Should generate com.plexapp.plugins.library.db-shm com.plexapp.plugins.library.db-wal on startup.)
    /usr/bin/app-plex start
    echo "----------------------------------"
    echo "Plex has been started with recovered DB!"
    echo "The old cleaned DB can be found in $HOME/plexbackup but YMMV with this DB if you need it anyway."
    echo "----------------------------------"
    exit 0
}

#Install updated version of SQLite3 since its way out of date and cant use .recover. 
sqlite3()
{
    echo "Have you installed the newest version of sqlite3?"
    echo "y/n"
    read -p "yes(y) / no(n):- " sqlite3response
    if [ "$sqlite3response" = "y" ]; then 
        echo "Not Updating."
    elif [ "$sqlite3response" = "n" ];then
        mkdir -p "$HOME"/scripts
        wget -O "$HOME"/scripts/sqlite-installer.sh https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/Language%20Installers/sqlite-installer.sh
        chmod +x "$HOME"/scripts/sqlite-installer.sh
        "$HOME"/scripts/sqlite-installer.sh
        echo "----------------------------------"
        echo "Finished! Cleaning up!"
        echo "----------------------------------"
        sleep 5
        clear
    else 
        echo "Wrong!"
        exit
    fi
}

# Corruption check for user. 
corruption()
{
    echo "----------------------------------"
    echo "Checking for corruption If the result comes back as “ok”, then the database file structure appears to be valid. It’s still possible that there may be other issues that haven’t been detected, such as incorrect formatting in the data itself."
    echo "----------------------------------"
   "$HOME"/bin/sqlite3 "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" "PRAGMA integrity_check;"
    echo "----------------------------------"
    echo "We will still continue the repair..."
    echo "----------------------------------"
    sleep 3
}

# Start main of script

printf "\033[0;31mDisclaimer: This installer is unofficial and USB staff will not support any issues with it\033[0m\n"
read -p "Type confirm if you wish to continue: " input
if [ ! "$input" = "confirm" ]
then
     exit
fi

echo "----------------------------------"
echo "Hello, time to do the plex dance."
echo "----------------------------------"
echo "          /          \O_ "
echo "       \_\         /\/   "
echo "          \         /    "
echo "          /O\       \    "
echo "----------------------------------"
sleep 3
clear

#Lets stop plex before recovering DB obviously
echo "We are going to check if plex is running. If it is we are going to stop it. "
if pgrep "Plex" > /dev/null;
then
    echo "Plex was found running, stopping in 3 seconds."
    sleep 3
    /usr/bin/app-plex stop
    echo "Checking if still running..."
    sleep 1
    clear
fi

# Do another check to make sure its 100% stopped.
if pgrep "Plex" > /dev/null;
then
    echo "Plex is still running! Please stop in UCP and rerun script. :("
    exit 1
else 
    echo "Passed final stop check."
    sleep 2
    clear
    sqlite3
    corruption
    repair
fi
