#!/bin/bash

/usr/bin/pip3 install --user -q --no-cache-dir --disable-pip-version-check halo

read -rp "Enter the application name to upgrade: " appname

/usr/bin/python3 - <<END_SCRIPT
import os
import sys
import subprocess
from subprocess import check_output, check_call
#list-of-applications
app_list = ['plex', 'radarr', 'sonarr', 'airsonic', 'bazarr', 'btsync', 'emby', 'jackett', 'jdownloader2', 'jellyfin', 'lazylibrarian', 'lidarr', 'mylar3', 'nzbget', 'nzbhydra2', 'ombi', 'overseerr', 'prowlarr', 'pyload', 'readarr', 'requestrr', 'sabnzbd', 'sickchill', 'syncthing', 'tautulli', 'ubooquity', 'thelounge', 'znc']
#install halo package if it's not there
def package_install(package):
    subprocess.call(["/usr/bin/pip3", "install", "--user", "-q", "--no-cache-dir", "--disable-pip-version-check", package])
    os.execl(sys.executable, sys.executable, *sys.argv) #re-compile code
# App upgrade function
def app_upgrade():
    import halo
    spinner = halo.Halo(text='In-Progress', text_color='magenta', spinner='bouncingBar')
    appname = "${appname}"
    if appname not in app_list:
        print("{} is not a supported docker application".format(appname))
        exit()
    spinner.start()
    count = 1
    while True:
        status = check_output("app-{appname} upgrade".format(appname=appname), shell=True)
        status = status.decode("utf-8")
        if "true" in status:
            spinner.stop()
            print("[SUCCESS] Upgrade Count:", count)
            break
        elif "false" in status:
            count +=1
def importhalo_runcode():
    try:
        check_halo = os.popen("/usr/bin/pip3 list | grep halo").read()
        if not check_halo:
            package_install('halo')
    except Exception as e:
        print("Unable to install halo module. Try manually 'pip3 install halo'")
    finally:
        app_upgrade()
def main():
    importhalo_runcode()
if __name__ == '__main__':
    main()
END_SCRIPT

exit
