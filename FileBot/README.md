# FileBot
## Prerequisites

For the installers and the AMC scripts hosted here to work, you may have to do the following:

* Uninstall FileBot from the UCP
* Purchase a FileBot License and upload it to your slot using FTPS/SFTP

## Installation

### Version 4.9.3 (Recommended)
You can install this version using the instructions below:

1. `wget https://raw.githubusercontent.com/ultraseedbox/UltraSeedbox-Scripts/master/FileBot/filebot-493-installer.sh`
2. `chmod +x filebot-493-installer.sh` (no terminal output expected)
3. `./filebot-493-installer.sh`
4. `rm filebot-493-installer.sh`
5. `filebot --license /path/to/FileBot_License_P1234567.psm`

### AMC/ Torrent Client Post-processing

If you're using FileBot for your torrent client post-processing, refer to the [AMC folder.](https://github.com/ultraseedbox/UltraSeedbox-Scripts/tree/master/FileBot/AMC)

## Uninstallation

### Version 4.9.3

1. `rm -rfv "$HOME"/filebot-493`
2. `rm "$HOME"/bin/filebot`

### Version 4.9.2

1. `rm -rfv "$HOME"/filebot-492`
2. `rm "$HOME"/bin/filebot`

### Version 4.9.1

1. `rm -rfv "$HOME"/filebot-491`
2. `rm "$HOME"/bin/filebot`

## Issues/Bugs

For any issues/bugs pertaining to FileBot, you may do so to the following channels:

1. [FileBot Forums](https://www.filebot.net/forums/)
2. [FileBot Subreddit](https://www.reddit.com/r/filebot/)
3. [FileBot Discord Server](https://discord.gg/skTt2em)