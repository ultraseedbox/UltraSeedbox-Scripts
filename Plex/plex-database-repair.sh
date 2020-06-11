#!/bin/bash
# by finch #0853

# This is the repair function, could probably be cleaned up but works. 
repair()
{
    # Create a rar backup for restore script.
    echo "----------------------------------"
    echo "Creating a backup of the plex databases directory for safe keeping."
    echo "----------------------------------"
    mkdir "$HOME"/plexbackup
    rar a "$HOME"/plexbackup/plexdb.rar "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/*"
    echo "----------------------------------"
    echo "Done!"
    echo "----------------------------------"
    sleep 5
    clear
    # Following guide per plexs instructions.
    echo "----------------------------------"
    echo "Repairing now with sqlite tools"
    echo "----------------------------------"
    sleep 2
    echo "Working in directory "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/tmp""
    cd "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
    sleep 2
    # Creating TMP directory for us to work in and moving the DB inside.
    mkdir tmp
    mv com.plexapp.plugins.library.db tmp/com.plexapp.plugins.library.db
    cd tmp
    # Running repair commands
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db "DROP index 'index_title_sort_naturalsort'"
    sleep 1
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db "DELETE from schema_migrations where version='20180501000000'"
    sleep 1
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db .dump > dump.sql
    sleep 1
    rm com.plexapp.plugins.library.db
    sleep 1
    "$HOME"/bin/sqlite3 com.plexapp.plugins.library.db < dump.sql
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
    cd "$HOME/.config/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
    rm -r "tmp"
    # Starting plex server again and exiting with good code. (Should generate com.plexapp.plugins.library.db-shm com.plexapp.plugins.library.db-wal on startup.)
    /usr/bin/app-plex start
    echo "----------------------------------"
    echo "Plex has been started with recovered DB!"
    echo "The old DB can be found in "$HOME/plexbackup""
    echo "----------------------------------"
    exit 0
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
fi

# Start the DB Recovery
if [[ -e ""$HOME"/bin/sqlite3" ]]; 
then
    repair
else
    echo "----------------------------------"
    echo "Sqlite3 was not found! :( "
    echo "Installing sqlite3 for you."
    echo "You will get another prompt to run a script to install Sqlite3. The recovery process will continue once installed."
    echo "----------------------------------"
    sleep 2
    mkdir -p "$HOME"/scripts
    wget -O "$HOME"/scripts/sqlite-installer.sh https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/Language%20Installers/sqlite-installer.sh
    chmod +x "$HOME"/scripts/sqlite-installer.sh
    "$HOME"/scripts/sqlite-installer.sh
    echo "----------------------------------"
    echo "Finished! Cleaning up!"
    echo "----------------------------------"
    sleep 5
    clear
    repair
fi
